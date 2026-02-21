import 'package:hms_app/utils/constants.dart';

class Permissions {
  /// Check if a role can access dashboard
  static bool canAccessDashboard(UserRole role) => true;

  /// Check if a role can manage bookings (create/edit/cancel)
  static bool canManageBookings(UserRole role) => [
    UserRole.admin,
    UserRole.manager,
    UserRole.receptionist,
  ].contains(role);

  /// Check if a role can manage rooms
  static bool canManageRooms(UserRole role) => [
    UserRole.admin,
    UserRole.manager,
    UserRole.receptionist,
  ].contains(role);

  /// Check if a role can manage guests
  static bool canManageGuests(UserRole role) => [
    UserRole.admin,
    UserRole.manager,
    UserRole.receptionist,
  ].contains(role);

  /// Check if a role can manage housekeeping
  static bool canManageHousekeeping(UserRole role) => [
    UserRole.admin,
    UserRole.manager,
    UserRole.housekeeper,
  ].contains(role);

  /// Check if a role can manage maintenance
  static bool canManageMaintenance(UserRole role) => [
    UserRole.admin,
    UserRole.manager,
    UserRole.maintenance,
  ].contains(role);

  /// Check if a role can manage billing/invoicing
  static bool canManageBilling(UserRole role) => [
    UserRole.admin,
    UserRole.manager,
    UserRole.accountant,
    UserRole.receptionist,
  ].contains(role);

  /// Check if a role can manage inventory
  static bool canManageInventory(UserRole role) => [
    UserRole.admin,
    UserRole.manager,
  ].contains(role);

  /// Check if a role can view reports
  static bool canViewReports(UserRole role) => [
    UserRole.admin,
    UserRole.manager,
    UserRole.accountant,
  ].contains(role);

  /// Check if a role can view audit logs
  static bool canViewAuditLogs(UserRole role) => [
    UserRole.admin,
    UserRole.manager,
  ].contains(role);

  /// Check if a role can manage settings
  static bool canManageSettings(UserRole role) => [
    UserRole.admin,
  ].contains(role);

  /// Check if a role can manage users
  static bool canManageUsers(UserRole role) => [
    UserRole.admin,
  ].contains(role);

  /// Check if a role can perform check-in/check-out
  static bool canCheckInOut(UserRole role) => [
    UserRole.admin,
    UserRole.manager,
    UserRole.receptionist,
  ].contains(role);

  /// Check if a role can approve maintenance costs
  static bool canApproveMaintenanceCosts(UserRole role) => [
    UserRole.admin,
    UserRole.manager,
  ].contains(role);

  /// Check if a role can force checkout (skip payment)
  static bool canForceCheckout(UserRole role) => [
    UserRole.admin,
    UserRole.manager,
  ].contains(role);
}
