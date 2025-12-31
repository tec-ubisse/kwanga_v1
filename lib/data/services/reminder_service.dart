import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;

import '../../models/task_model.dart';

class ReminderService {
  static final FlutterLocalNotificationsPlugin _plugin =
  FlutterLocalNotificationsPlugin();

  static const String _channelId = 'tasks';
  static const String _channelName = 'Lembretes de tarefas';
  static const String _channelDescription =
      'Notificações de lembrete das tarefas';

  // -------------------------------------------------------------
  // INIT
  // -------------------------------------------------------------
  static Future<void> init() async {
    try {
      // 🔥 Inicializar timezones
      tzdata.initializeTimeZones();

      // 🔥 Timezone explícito (Moçambique)
      tz.setLocalLocation(tz.getLocation('Africa/Maputo'));
      debugPrint('✅ Timezone configurado: ${tz.local.name}');

      const androidInit =
      AndroidInitializationSettings('@mipmap/ic_launcher');

      const settings = InitializationSettings(
        android: androidInit,
      );

      await _plugin.initialize(
        settings,
        onDidReceiveNotificationResponse: (details) {
          debugPrint('📬 Notificação clicada: ${details.payload}');
        },
      );

      final androidImpl = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

      if (androidImpl != null) {
        // 🔔 Android 13+
        final granted = await androidImpl.requestNotificationsPermission();
        debugPrint('📱 Permissão de notificações: ${granted ?? false}');

        // 📢 Criar canal explicitamente
        const channel = AndroidNotificationChannel(
          _channelId,
          _channelName,
          description: _channelDescription,
          importance: Importance.max,
          playSound: true,
          enableVibration: true,
        );

        await androidImpl.createNotificationChannel(channel);
        debugPrint('📢 Canal criado: $_channelId');
      }

      debugPrint('✅ ReminderService inicializado com sucesso');
    } catch (e, stack) {
      debugPrint('❌ Erro ao inicializar ReminderService: $e');
      debugPrint('Stack trace: $stack');
    }
  }

  // -------------------------------------------------------------
  // ID ESTÁVEL DA NOTIFICAÇÃO
  // -------------------------------------------------------------
  static int _id(TaskModel task) {
    return task.id.hashCode.abs();
  }

  // -------------------------------------------------------------
  // SCHEDULE / UPDATE
  // -------------------------------------------------------------
  static Future<void> schedule(TaskModel task) async {
    try {
      final dateTime = _reminderDateTime(task);

      // Sem lembrete → cancelar
      if (dateTime == null) {
        debugPrint('⏭️ Sem lembrete: ${task.description}');
        await cancel(task);
        return;
      }

      final now = DateTime.now();

      // 🔥 Nunca agendar no passado
      if (dateTime.isBefore(now)) {
        debugPrint(
          '⚠️ Lembrete no passado ignorado: $dateTime (${task.description})',
        );
        await cancel(task);
        return;
      }

      final scheduledDate = tz.TZDateTime.from(dateTime, tz.local);

      debugPrint('📅 Agendando lembrete');
      debugPrint('   ID: ${_id(task)}');
      debugPrint('   Tarefa: ${task.description}');
      debugPrint('   Data/Hora: $scheduledDate');
      debugPrint('   Timezone: ${tz.local.name}');

      await _plugin.zonedSchedule(
        _id(task),
        'Lembrete',
        task.description,
        scheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: _channelDescription,
            importance: Importance.max,
            priority: Priority.max,
            category: AndroidNotificationCategory.reminder,
            visibility: NotificationVisibility.public,
            enableVibration: true,
            playSound: true,
            ticker: 'Lembrete de tarefa',
          ),
        ),

        // 🔑 Android 15 → usar INEXACT
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );


      debugPrint('✅ Lembrete agendado com sucesso');
      await _listPendingNotifications();
    } catch (e, stack) {
      debugPrint('❌ Erro ao agendar lembrete: $e');
      debugPrint('Stack trace: $stack');
    }
  }

  // -------------------------------------------------------------
  // CANCEL
  // -------------------------------------------------------------
  static Future<void> cancel(TaskModel task) async {
    try {
      await _plugin.cancel(_id(task));
      debugPrint('🗑️ Lembrete cancelado: ${task.description}');
    } catch (e) {
      debugPrint('❌ Erro ao cancelar lembrete: $e');
    }
  }

  // -------------------------------------------------------------
  // DEBUG: LISTAR NOTIFICAÇÕES PENDENTES
  // -------------------------------------------------------------
  static Future<void> _listPendingNotifications() async {
    try {
      final pending = await _plugin.pendingNotificationRequests();
      debugPrint('📋 Notificações pendentes: ${pending.length}');
      for (final n in pending) {
        debugPrint('   • ID: ${n.id} | ${n.title}');
      }
    } catch (e) {
      debugPrint('❌ Erro ao listar pendentes: $e');
    }
  }

  // -------------------------------------------------------------
  // REGRA ÚNICA DE CÁLCULO DO LEMBRETE
  // -------------------------------------------------------------
  static DateTime? _reminderDateTime(TaskModel task) {
    if (task.deadline == null && task.time == null) {
      debugPrint('⚠️ Sem deadline/time: ${task.description}');
      return null;
    }

    final date = task.deadline ?? DateTime.now();

    // Só data → 09:00
    if (task.time == null) {
      final reminder = DateTime(date.year, date.month, date.day, 9);
      debugPrint('📅 Usando 09:00: $reminder');
      return reminder;
    }

    final reminder = DateTime(
      date.year,
      date.month,
      date.day,
      task.time!.hour,
      task.time!.minute,
    );

    debugPrint('📅 Lembrete calculado: $reminder');
    return reminder;
  }
}
