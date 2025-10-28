class LifeArea {
  final String  id;
  final int userId;
  final String designation;
  final String iconPath;
  final bool isDeleted;
  final bool isSynced;
  final bool isDefault;
  final String createdAt;
  final String updatedAt;


  LifeArea(
      this.designation,
      this.iconPath,
      this.id, {
        this.userId = 0,
        this.isDeleted = false,
        this.isSynced = false,
        this.isDefault = false,
        this.createdAt = '',
        this.updatedAt = '',
      });
}
