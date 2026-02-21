import 'package:flutter/material.dart';
import 'package:hms_app/config/theme.dart';

// === User Roles ===
enum UserRole {
  admin,
  manager,
  receptionist,
  housekeeper,
  maintenance,
  accountant,
  staff;

  String get label => switch (this) {
    admin => 'Admin',
    manager => 'Manager',
    receptionist => 'Receptionist',
    housekeeper => 'Housekeeper',
    maintenance => 'Maintenance',
    accountant => 'Accountant',
    staff => 'Staff',
  };
}

// === Room Status ===
enum RoomStatus {
  available('Available'),
  occupied('Occupied'),
  maintenance('Maintenance'),
  dirty('Dirty');

  final String label;
  const RoomStatus(this.label);

  Color get color => switch (this) {
    available => AppTheme.availableColor,
    occupied => AppTheme.occupiedColor,
    maintenance => AppTheme.maintenanceColor,
    dirty => AppTheme.dirtyColor,
  };

  IconData get icon => switch (this) {
    available => Icons.check_circle_outline,
    occupied => Icons.person,
    maintenance => Icons.build_outlined,
    dirty => Icons.cleaning_services_outlined,
  };
}

// === Booking Status ===
enum BookingStatus {
  pending('Pending'),
  confirmed('Confirmed'),
  checkedIn('CheckedIn'),
  checkedOut('CheckedOut'),
  cancelled('Cancelled');

  final String label;
  const BookingStatus(this.label);

  Color get color => switch (this) {
    pending => AppTheme.pendingColor,
    confirmed => AppTheme.confirmedColor,
    checkedIn => AppTheme.checkedInColor,
    checkedOut => AppTheme.checkedOutColor,
    cancelled => AppTheme.cancelledColor,
  };

  IconData get icon => switch (this) {
    pending => Icons.schedule,
    confirmed => Icons.check,
    checkedIn => Icons.login,
    checkedOut => Icons.logout,
    cancelled => Icons.cancel_outlined,
  };
}

// === Payment Status ===
enum PaymentStatus {
  pending('Pending'),
  completed('Completed'),
  failed('Failed'),
  refunded('Refunded');

  final String label;
  const PaymentStatus(this.label);

  Color get color => switch (this) {
    pending => AppTheme.pendingColor,
    completed => AppTheme.paidColor,
    failed => AppTheme.errorColor,
    refunded => AppTheme.infoColor,
  };
}

// === Invoice Status ===
enum InvoiceStatus {
  draft('Draft'),
  unpaid('Unpaid'),
  paid('Paid'),
  void_('Void');

  final String label;
  const InvoiceStatus(this.label);

  Color get color => switch (this) {
    draft => AppTheme.noInvoiceColor,
    unpaid => AppTheme.unpaidColor,
    paid => AppTheme.paidColor,
    void_ => AppTheme.noInvoiceColor,
  };
}

// === Charge Type ===
enum ChargeType {
  room('Room'),
  laundry('Laundry'),
  restaurant('Restaurant'),
  damage('Damage'),
  lateFee('LateFee'),
  discount('Discount'),
  other('Other');

  final String label;
  const ChargeType(this.label);
}

// === Charge Status ===
enum ChargeStatus {
  pending('Pending'),
  paid('Paid'),
  invoiced('Invoiced'),
  waived('Waived');

  final String label;
  const ChargeStatus(this.label);
}

// === Payment Method ===
enum PaymentMethod {
  creditCard('Credit Card'),
  paypal('PayPal'),
  bankTransfer('Bank Transfer'),
  cash('Cash');

  final String label;
  const PaymentMethod(this.label);

  IconData get icon => switch (this) {
    creditCard => Icons.credit_card,
    paypal => Icons.payment,
    bankTransfer => Icons.account_balance,
    cash => Icons.money,
  };
}

// === Housekeeping Status ===
enum HousekeepingStatus {
  pending('Pending'),
  inProgress('In Progress'),
  completed('Completed');

  final String label;
  const HousekeepingStatus(this.label);

  Color get color => switch (this) {
    pending => AppTheme.pendingColor,
    inProgress => AppTheme.infoColor,
    completed => AppTheme.successColor,
  };
}

// === Maintenance Status ===
enum MaintenanceStatus {
  open('Open'),
  inProgress('In Progress'),
  resolved('Resolved');

  final String label;
  const MaintenanceStatus(this.label);

  Color get color => switch (this) {
    open => AppTheme.errorColor,
    inProgress => AppTheme.pendingColor,
    resolved => AppTheme.successColor,
  };
}

// === Maintenance Priority ===
enum MaintenancePriority {
  low('Low'),
  medium('Medium'),
  high('High');

  final String label;
  const MaintenancePriority(this.label);

  Color get color => switch (this) {
    low => AppTheme.lowPriorityColor,
    medium => AppTheme.mediumPriorityColor,
    high => AppTheme.highPriorityColor,
  };

  IconData get icon => switch (this) {
    low => Icons.arrow_downward,
    medium => Icons.remove,
    high => Icons.arrow_upward,
  };
}

// === Notification Type ===
enum NotificationType {
  email('Email'),
  sms('SMS'),
  push('Push');

  final String label;
  const NotificationType(this.label);
}

// === Notification Status ===
enum NotificationStatus {
  pending('Pending'),
  sent('Sent'),
  failed('Failed');

  final String label;
  const NotificationStatus(this.label);
}

// === Loyalty Tier ===
enum LoyaltyTier {
  none('None'),
  bronze('Bronze'),
  silver('Silver'),
  gold('Gold');

  final String label;
  const LoyaltyTier(this.label);

  Color get color => switch (this) {
    none => AppTheme.noneLoyaltyColor,
    bronze => AppTheme.bronzeLoyaltyColor,
    silver => AppTheme.silverLoyaltyColor,
    gold => AppTheme.goldLoyaltyColor,
  };

  IconData get icon => switch (this) {
    none => Icons.person_outline,
    bronze => Icons.star_outline,
    silver => Icons.star_half,
    gold => Icons.star,
  };
}
