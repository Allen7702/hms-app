import 'dart:convert';
import 'package:hms_app/local_db/app_database.dart';
import 'package:hms_app/models/app_notification.dart';
import 'package:hms_app/models/audit_log.dart';
import 'package:hms_app/models/booking.dart';
import 'package:hms_app/models/charge.dart';
import 'package:hms_app/models/guest.dart';
import 'package:hms_app/models/hotel.dart';
import 'package:hms_app/models/housekeeping.dart';
import 'package:hms_app/models/inventory_category.dart';
import 'package:hms_app/models/inventory_item.dart';
import 'package:hms_app/models/inventory_transaction.dart';
import 'package:hms_app/models/invoice.dart';
import 'package:hms_app/models/maintenance.dart';
import 'package:hms_app/models/payment.dart';
import 'package:hms_app/models/reorder_alert.dart';
import 'package:hms_app/models/room.dart';
import 'package:hms_app/models/room_inventory.dart';
import 'package:hms_app/models/room_type.dart';
import 'package:hms_app/models/user.dart';

Map<String, dynamic>? _decodeMap(String? s) =>
    s != null ? (jsonDecode(s) as Map<String, dynamic>) : null;

// ─── Core ─────────────────────────────────────────────────────────────────────

extension LocalUserToModel on LocalUser {
  User toModel() => User(
        id: id,
        fullName: fullName,
        username: username,
        email: email,
        phone: phone,
        role: role,
        isActive: isActive,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}

extension LocalHotelToModel on LocalHotel {
  Hotel toModel() => Hotel(
        id: id,
        name: name,
        address: address,
        phone: phone,
        email: email,
        website: website,
        settings: _decodeMap(settings),
        isActive: isActive,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}

extension LocalRoomTypeToModel on LocalRoomType {
  RoomType toModel() => RoomType(
        id: id,
        name: name,
        description: description,
        capacity: capacity,
        price: price,
        priceModifier: priceModifier,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}

extension LocalRoomToModel on LocalRoom {
  Room toModel() => Room(
        id: id,
        roomNumber: roomNumber,
        floor: floor,
        roomTypeId: roomTypeId,
        status: status,
        features: _decodeMap(features),
        lastCleaned: lastCleaned,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}

extension LocalGuestToModel on LocalGuest {
  Guest toModel() => Guest(
        id: id,
        name: name,
        email: email,
        phone: phone,
        address: address,
        nationality: nationality,
        idNumber: idNumber,
        preferences: _decodeMap(preferences),
        loyaltyPoints: loyaltyPoints,
        loyaltyTier: loyaltyTier,
        gdprConsent: gdprConsent,
        totalStays: totalStays,
        totalSpent: totalSpent,
        lastStayDate: lastStayDate,
        preferredRoomType: preferredRoomType,
        notes: notes,
        userId: userId,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}

// ─── Bookings ─────────────────────────────────────────────────────────────────

extension LocalBookingToModel on LocalBooking {
  Booking toModel() => Booking(
        id: id,
        guestId: guestId,
        roomId: roomId,
        checkIn: checkIn,
        checkOut: checkOut,
        status: status,
        source: source,
        rateApplied: rateApplied,
        adults: adults,
        children: children,
        specialRequests: specialRequests,
        notes: notes,
        modificationReason: modificationReason,
        paymentStatus: paymentStatus,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}

// ─── Billing ──────────────────────────────────────────────────────────────────

extension LocalInvoiceToModel on LocalInvoice {
  Invoice toModel() => Invoice(
        id: id,
        bookingId: bookingId,
        amount: amount,
        tax: tax,
        invoiceNumber: invoiceNumber,
        status: status,
        issueDate: issueDate,
        dueDate: dueDate,
        paidAt: paidAt,
        notes: notes,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}

extension LocalPaymentToModel on LocalPayment {
  Payment toModel() => Payment(
        id: id,
        invoiceId: invoiceId,
        amount: amount,
        status: status,
        method: method,
        transactionId: transactionId,
        processedAt: processedAt,
        createdAt: createdAt,
      );
}

extension LocalChargeToModel on LocalCharge {
  Charge toModel() => Charge(
        id: id,
        bookingId: bookingId,
        invoiceId: invoiceId,
        chargeType: chargeType,
        description: description,
        amount: amount,
        quantity: quantity,
        status: status,
        paymentMethod: paymentMethod,
        paymentReference: paymentReference,
        paidAt: paidAt,
        paidAmount: paidAmount,
        addedBy: addedBy,
        serviceDate: serviceDate,
        notes: notes,
        createdAt: createdAt,
      ); // Charge has no updatedAt field
}

// ─── Operations ───────────────────────────────────────────────────────────────

extension LocalHousekeepingToModel on LocalHousekeeping {
  Housekeeping toModel() => Housekeeping(
        id: id,
        roomId: roomId,
        status: status,
        assigneeId: assigneeId,
        scheduledDate: scheduledDate,
        completedAt: completedAt,
        notes: notes,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}

extension LocalMaintenanceToModel on LocalMaintenance {
  Maintenance toModel() => Maintenance(
        id: id,
        roomId: roomId,
        description: description,
        status: status,
        priority: priority,
        assigneeId: assigneeId,
        estimatedCost: estimatedCost,
        actualCost: actualCost,
        costNotes: costNotes,
        laborCost: laborCost,
        materialsCost: materialsCost,
        contractorCost: contractorCost,
        costApprovedBy: costApprovedBy,
        requiresApproval: requiresApproval,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}

// ─── Inventory ────────────────────────────────────────────────────────────────

extension LocalInventoryCategoryToModel on LocalInventoryCategory {
  InventoryCategory toModel() => InventoryCategory(
        id: id,
        hotelId: hotelId,
        name: name,
        categoryType: categoryType,
        description: description,
        isActive: isActive,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}

extension LocalInventoryItemToModel on LocalInventoryItem {
  InventoryItem toModel() => InventoryItem(
        id: id,
        hotelId: hotelId,
        categoryId: categoryId,
        name: name,
        sku: sku,
        unit: unit,
        currentStock: currentStock,
        minimumStock: minimumStock,
        maximumStock: maximumStock,
        reorderQuantity: reorderQuantity,
        unitCost: unitCost,
        sellingPrice: sellingPrice,
        storageLocation: storageLocation,
        isPerishable: isPerishable,
        expirationDays: expirationDays,
        lastRestockDate: lastRestockDate,
        isActive: isActive,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}

extension LocalInventoryTransactionToModel on LocalInventoryTransaction {
  InventoryTransaction toModel() => InventoryTransaction(
        id: id,
        hotelId: hotelId,
        itemId: itemId,
        transactionType: transactionType,
        quantity: quantity,
        previousStock: previousStock,
        newStock: newStock,
        referenceType: referenceType,
        referenceId: referenceId,
        roomId: roomId,
        bookingId: bookingId,
        unitCostAtTime: unitCostAtTime,
        notes: notes,
        performedBy: performedBy,
        createdAt: createdAt,
      );
}

extension LocalRoomInventoryToModel on LocalRoomInventory {
  RoomInventory toModel() => RoomInventory(
        id: id,
        hotelId: hotelId,
        roomId: roomId,
        itemId: itemId,
        parLevel: parLevel,
        currentQuantity: currentQuantity,
        lastChecked: lastChecked,
        lastCheckedBy: lastCheckedBy,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}

extension LocalReorderAlertToModel on LocalReorderAlert {
  ReorderAlert toModel() => ReorderAlert(
        id: id,
        hotelId: hotelId,
        itemId: itemId,
        currentStock: currentStock,
        minimumStock: minimumStock,
        suggestedQuantity: suggestedQuantity,
        status: status,
        acknowledgedBy: acknowledgedBy,
        acknowledgedAt: acknowledgedAt,
        resolvedBy: resolvedBy,
        resolvedAt: resolvedAt,
        notes: notes,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}

// ─── Notifications & Audit ────────────────────────────────────────────────────

extension LocalNotificationToModel on LocalNotification {
  AppNotification toModel() => AppNotification(
        id: id,
        type: type,
        guestId: guestId,
        userId: userId,
        recipient: recipient,
        message: message,
        status: status,
        relatedEntityId: relatedEntityId,
        entityType: entityType,
        createdAt: createdAt,
      ); // AppNotification has no updatedAt field
}

extension LocalAuditLogToModel on LocalAuditLog {
  AuditLog toModel() => AuditLog(
        id: id,
        action: action,
        userId: userId,
        entityType: entityType,
        entityId: entityId,
        details: _decodeMap(details),
        dataBefore: _decodeMap(dataBefore),
        dataAfter: _decodeMap(dataAfter),
        createdAt: createdAt,
      );
}
