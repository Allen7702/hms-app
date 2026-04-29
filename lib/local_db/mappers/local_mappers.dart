import 'package:drift/drift.dart';
import '../app_database.dart';

// ─── Type helpers ─────────────────────────────────────────────────────────────

int? _i(dynamic v) => v == null ? null : (v as num).toInt();
String? _s(dynamic v) => v?.toString();
bool? _b(dynamic v) => v == null ? null : v as bool;
double? _d(dynamic v) => v == null ? null : (v as num).toDouble();

// ─── Core ─────────────────────────────────────────────────────────────────────

UsersTableCompanion userFromMap(Map<String, dynamic> m) =>
    UsersTableCompanion(
      id: Value(_i(m['id'])!),
      fullName: Value(_s(m['full_name'])),
      username: Value(_s(m['username'])),
      email: Value(_s(m['email'])),
      phone: Value(_s(m['phone'])),
      role: Value(_s(m['role'])),
      isActive: Value(_b(m['is_active'])),
      createdAt: Value(_s(m['created_at'])),
      updatedAt: Value(_s(m['updated_at'])),
    );

HotelsTableCompanion hotelFromMap(Map<String, dynamic> m) =>
    HotelsTableCompanion(
      id: Value(_i(m['id'])!),
      name: Value(_s(m['name'])),
      logoUrl: Value(_s(m['logo_url'])),
      address: Value(_s(m['address'])),
      phone: Value(_s(m['phone'])),
      email: Value(_s(m['email'])),
      website: Value(_s(m['website'])),
      description: Value(_s(m['description'])),
      settings: Value(_s(m['settings'])),
      isActive: Value(_b(m['is_active'])),
      createdAt: Value(_s(m['created_at'])),
      updatedAt: Value(_s(m['updated_at'])),
    );

RoomTypesTableCompanion roomTypeFromMap(Map<String, dynamic> m) =>
    RoomTypesTableCompanion(
      id: Value(_i(m['id'])!),
      name: Value(_s(m['name'])),
      description: Value(_s(m['description'])),
      capacity: Value(_i(m['capacity'])),
      price: Value(_i(m['price'])),
      priceModifier: Value(_i(m['price_modifier'])),
      createdAt: Value(_s(m['created_at'])),
      updatedAt: Value(_s(m['updated_at'])),
    );

RoomsTableCompanion roomFromMap(Map<String, dynamic> m) =>
    RoomsTableCompanion(
      id: Value(_i(m['id'])!),
      roomNumber: Value(_s(m['room_number'])),
      floor: Value(_s(m['floor'])),
      roomTypeId: Value(_i(m['room_type_id'])),
      status: Value(_s(m['status'])),
      features: Value(_s(m['features'])),
      lastCleaned: Value(_s(m['last_cleaned'])),
      createdAt: Value(_s(m['created_at'])),
      updatedAt: Value(_s(m['updated_at'])),
    );

GuestsTableCompanion guestFromMap(Map<String, dynamic> m) =>
    GuestsTableCompanion(
      id: Value(_i(m['id'])!),
      name: Value(_s(m['name'])),
      email: Value(_s(m['email'])),
      phone: Value(_s(m['phone'])),
      address: Value(_s(m['address'])),
      nationality: Value(_s(m['nationality'])),
      idNumber: Value(_s(m['id_number'])),
      preferences: Value(_s(m['preferences'])),
      loyaltyPoints: Value(_i(m['loyalty_points'])),
      loyaltyTier: Value(_s(m['loyalty_tier'])),
      gdprConsent: Value(_b(m['gdpr_consent'])),
      totalStays: Value(_i(m['total_stays'])),
      totalSpent: Value(_i(m['total_spent'])),
      lastStayDate: Value(_s(m['last_stay_date'])),
      preferredRoomType: Value(_s(m['preferred_room_type'])),
      notes: Value(_s(m['notes'])),
      userId: Value(_i(m['user_id'])),
      createdAt: Value(_s(m['created_at'])),
      updatedAt: Value(_s(m['updated_at'])),
    );

// ─── Bookings ─────────────────────────────────────────────────────────────────

BookingsTableCompanion bookingFromMap(Map<String, dynamic> m) =>
    BookingsTableCompanion(
      id: Value(_i(m['id'])!),
      guestId: Value(_i(m['guest_id'])),
      roomId: Value(_i(m['room_id'])),
      checkIn: Value(_s(m['check_in'])),
      checkOut: Value(_s(m['check_out'])),
      status: Value(_s(m['status'])),
      source: Value(_s(m['source'])),
      rateApplied: Value(_i(m['rate_applied'])),
      adults: Value(_i(m['adults'])),
      children: Value(_i(m['children'])),
      specialRequests: Value(_s(m['special_requests'])),
      notes: Value(_s(m['notes'])),
      modificationReason: Value(_s(m['modification_reason'])),
      paymentStatus: Value(_s(m['payment_status'])),
      createdAt: Value(_s(m['created_at'])),
      updatedAt: Value(_s(m['updated_at'])),
    );

OtaReservationsTableCompanion otaReservationFromMap(Map<String, dynamic> m) =>
    OtaReservationsTableCompanion(
      id: Value(_i(m['id'])!),
      bookingId: Value(_i(m['booking_id'])),
      otaId: Value(_s(m['ota_id'])),
      otaName: Value(_s(m['ota_name'])),
      createdAt: Value(_s(m['created_at'])),
      updatedAt: Value(_s(m['updated_at'])),
    );

// ─── Billing ──────────────────────────────────────────────────────────────────

InvoicesTableCompanion invoiceFromMap(Map<String, dynamic> m) =>
    InvoicesTableCompanion(
      id: Value(_i(m['id'])!),
      bookingId: Value(_i(m['booking_id'])),
      amount: Value(_i(m['amount'])),
      tax: Value(_i(m['tax'])),
      invoiceNumber: Value(_s(m['invoice_number'])),
      status: Value(_s(m['status'])),
      issueDate: Value(_s(m['issue_date'])),
      dueDate: Value(_s(m['due_date'])),
      paidAt: Value(_s(m['paid_at'])),
      notes: Value(_s(m['notes'])),
      createdAt: Value(_s(m['created_at'])),
      updatedAt: Value(_s(m['updated_at'])),
    );

PaymentsTableCompanion paymentFromMap(Map<String, dynamic> m) =>
    PaymentsTableCompanion(
      id: Value(_i(m['id'])!),
      invoiceId: Value(_i(m['invoice_id'])),
      amount: Value(_i(m['amount'])),
      status: Value(_s(m['status'])),
      method: Value(_s(m['method'])),
      transactionId: Value(_s(m['transaction_id'])),
      processedAt: Value(_s(m['processed_at'])),
      createdAt: Value(_s(m['created_at'])),
    );

ChargesTableCompanion chargeFromMap(Map<String, dynamic> m) =>
    ChargesTableCompanion(
      id: Value(_i(m['id'])!),
      bookingId: Value(_i(m['booking_id'])),
      invoiceId: Value(_i(m['invoice_id'])),
      chargeType: Value(_s(m['charge_type'])),
      description: Value(_s(m['description'])),
      amount: Value(_i(m['amount'])),
      quantity: Value(_i(m['quantity'])),
      status: Value(_s(m['status'])),
      paymentMethod: Value(_s(m['payment_method'])),
      paymentReference: Value(_s(m['payment_reference'])),
      paidAt: Value(_s(m['paid_at'])),
      paidAmount: Value(_i(m['paid_amount'])),
      addedBy: Value(_s(m['added_by'])),
      serviceDate: Value(_s(m['service_date'])),
      notes: Value(_s(m['notes'])),
      createdAt: Value(_s(m['created_at'])),
      updatedAt: Value(_s(m['updated_at'])),
    );

// ─── Operations ───────────────────────────────────────────────────────────────

HousekeepingsTableCompanion housekeepingFromMap(Map<String, dynamic> m) =>
    HousekeepingsTableCompanion(
      id: Value(_i(m['id'])!),
      roomId: Value(_i(m['room_id'])),
      status: Value(_s(m['status'])),
      assigneeId: Value(_i(m['assignee_id'])),
      scheduledDate: Value(_s(m['scheduled_date'])),
      completedAt: Value(_s(m['completed_at'])),
      notes: Value(_s(m['notes'])),
      createdAt: Value(_s(m['created_at'])),
      updatedAt: Value(_s(m['updated_at'])),
    );

MaintenancesTableCompanion maintenanceFromMap(Map<String, dynamic> m) =>
    MaintenancesTableCompanion(
      id: Value(_i(m['id'])!),
      roomId: Value(_i(m['room_id'])),
      description: Value(_s(m['description'])),
      status: Value(_s(m['status'])),
      priority: Value(_s(m['priority'])),
      assigneeId: Value(_i(m['assignee_id'])),
      estimatedCost: Value(_d(m['estimated_cost'])),
      actualCost: Value(_d(m['actual_cost'])),
      costNotes: Value(_s(m['cost_notes'])),
      laborCost: Value(_d(m['labor_cost'])),
      materialsCost: Value(_d(m['materials_cost'])),
      contractorCost: Value(_d(m['contractor_cost'])),
      costBreakdown: Value(_s(m['cost_breakdown'])),
      costApprovedBy: Value(_i(m['cost_approved_by'])),
      requiresApproval: Value(_b(m['requires_approval'])),
      history: Value(_s(m['history'])),
      createdAt: Value(_s(m['created_at'])),
      updatedAt: Value(_s(m['updated_at'])),
    );

// ─── Inventory ────────────────────────────────────────────────────────────────

InventoryCategoriesTableCompanion inventoryCategoryFromMap(
        Map<String, dynamic> m) =>
    InventoryCategoriesTableCompanion(
      id: Value(_i(m['id'])!),
      hotelId: Value(_i(m['hotel_id'])),
      name: Value(_s(m['name'])),
      categoryType: Value(_s(m['category_type'])),
      description: Value(_s(m['description'])),
      isActive: Value(_b(m['is_active'])),
      createdAt: Value(_s(m['created_at'])),
      updatedAt: Value(_s(m['updated_at'])),
    );

InventoryItemsTableCompanion inventoryItemFromMap(Map<String, dynamic> m) =>
    InventoryItemsTableCompanion(
      id: Value(_i(m['id'])!),
      hotelId: Value(_i(m['hotel_id'])),
      categoryId: Value(_i(m['category_id'])),
      name: Value(_s(m['name'])),
      sku: Value(_s(m['sku'])),
      description: Value(_s(m['description'])),
      unit: Value(_s(m['unit'])),
      currentStock: Value(_i(m['current_stock'])),
      minimumStock: Value(_i(m['minimum_stock'])),
      maximumStock: Value(_i(m['maximum_stock'])),
      reorderQuantity: Value(_i(m['reorder_quantity'])),
      unitCost: Value(_i(m['unit_cost'])),
      sellingPrice: Value(_i(m['selling_price'])),
      storageLocation: Value(_s(m['storage_location'])),
      isPerishable: Value(_b(m['is_perishable'])),
      expirationDays: Value(_i(m['expiration_days'])),
      lastRestockDate: Value(_s(m['last_restock_date'])),
      isActive: Value(_b(m['is_active'])),
      createdAt: Value(_s(m['created_at'])),
      updatedAt: Value(_s(m['updated_at'])),
    );

InventoryTransactionsTableCompanion inventoryTransactionFromMap(
        Map<String, dynamic> m) =>
    InventoryTransactionsTableCompanion(
      id: Value(_i(m['id'])!),
      hotelId: Value(_i(m['hotel_id'])),
      itemId: Value(_i(m['item_id'])),
      transactionType: Value(_s(m['transaction_type'])),
      quantity: Value(_i(m['quantity'])),
      previousStock: Value(_i(m['previous_stock'])),
      newStock: Value(_i(m['new_stock'])),
      referenceType: Value(_s(m['reference_type'])),
      referenceId: Value(_i(m['reference_id'])),
      roomId: Value(_i(m['room_id'])),
      bookingId: Value(_i(m['booking_id'])),
      unitCostAtTime: Value(_i(m['unit_cost_at_time'])),
      notes: Value(_s(m['notes'])),
      performedBy: Value(_i(m['performed_by'])),
      createdAt: Value(_s(m['created_at'])),
    );

RoomInventoryTableCompanion roomInventoryFromMap(Map<String, dynamic> m) =>
    RoomInventoryTableCompanion(
      id: Value(_i(m['id'])!),
      hotelId: Value(_i(m['hotel_id'])),
      roomId: Value(_i(m['room_id'])),
      itemId: Value(_i(m['item_id'])),
      parLevel: Value(_i(m['par_level'])),
      currentQuantity: Value(_i(m['current_quantity'])),
      lastChecked: Value(_s(m['last_checked'])),
      lastCheckedBy: Value(_i(m['last_checked_by'])),
      lastRestocked: Value(_s(m['last_restocked'])),
      createdAt: Value(_s(m['created_at'])),
      updatedAt: Value(_s(m['updated_at'])),
    );

ReorderAlertsTableCompanion reorderAlertFromMap(Map<String, dynamic> m) =>
    ReorderAlertsTableCompanion(
      id: Value(_i(m['id'])!),
      hotelId: Value(_i(m['hotel_id'])),
      itemId: Value(_i(m['item_id'])),
      currentStock: Value(_i(m['current_stock'])),
      minimumStock: Value(_i(m['minimum_stock'])),
      suggestedQuantity: Value(_i(m['suggested_quantity'])),
      status: Value(_s(m['status'])),
      acknowledgedBy: Value(_i(m['acknowledged_by'])),
      acknowledgedAt: Value(_s(m['acknowledged_at'])),
      resolvedBy: Value(_i(m['resolved_by'])),
      resolvedAt: Value(_s(m['resolved_at'])),
      notes: Value(_s(m['notes'])),
      createdAt: Value(_s(m['created_at'])),
      updatedAt: Value(_s(m['updated_at'])),
    );

// ─── Expenses ─────────────────────────────────────────────────────────────────

ExpenseCategoriesTableCompanion expenseCategoryFromMap(
        Map<String, dynamic> m) =>
    ExpenseCategoriesTableCompanion(
      id: Value(_i(m['id'])!),
      hotelId: Value(_i(m['hotel_id'])),
      name: Value(_s(m['name'])),
      description: Value(_s(m['description'])),
      color: Value(_s(m['color'])),
      createdAt: Value(_s(m['created_at'])),
      updatedAt: Value(_s(m['updated_at'])),
    );

ExpensesTableCompanion expenseFromMap(Map<String, dynamic> m) =>
    ExpensesTableCompanion(
      id: Value(_i(m['id'])!),
      hotelId: Value(_i(m['hotel_id'])),
      categoryId: Value(_i(m['category_id'])),
      recurringId: Value(_i(m['recurring_id'])),
      maintenanceId: Value(_i(m['maintenance_id'])),
      title: Value(_s(m['title'])),
      amount: Value(_i(m['amount'])),
      expenseDate: Value(_s(m['expense_date'])),
      paymentMethod: Value(_s(m['payment_method'])),
      vendor: Value(_s(m['vendor'])),
      reference: Value(_s(m['reference'])),
      notes: Value(_s(m['notes'])),
      recordedBy: Value(_i(m['recorded_by'])),
      createdAt: Value(_s(m['created_at'])),
      updatedAt: Value(_s(m['updated_at'])),
    );

RecurringExpensesTableCompanion recurringExpenseFromMap(
        Map<String, dynamic> m) =>
    RecurringExpensesTableCompanion(
      id: Value(_i(m['id'])!),
      hotelId: Value(_i(m['hotel_id'])),
      categoryId: Value(_i(m['category_id'])),
      title: Value(_s(m['title'])),
      amount: Value(_i(m['amount'])),
      frequency: Value(_s(m['frequency'])),
      dayOfMonth: Value(_i(m['day_of_month'])),
      paymentMethod: Value(_s(m['payment_method'])),
      vendor: Value(_s(m['vendor'])),
      notes: Value(_s(m['notes'])),
      isActive: Value(_b(m['is_active'])),
      lastApplied: Value(_s(m['last_applied'])),
      startDate: Value(_s(m['start_date'])),
      endDate: Value(_s(m['end_date'])),
      createdAt: Value(_s(m['created_at'])),
      updatedAt: Value(_s(m['updated_at'])),
    );

// ─── POS ──────────────────────────────────────────────────────────────────────

PosCategoriesTableCompanion posCategoryFromMap(Map<String, dynamic> m) =>
    PosCategoriesTableCompanion(
      id: Value(_i(m['id'])!),
      hotelId: Value(_i(m['hotel_id'])),
      name: Value(_s(m['name'])),
      color: Value(_s(m['color'])),
      sortOrder: Value(_i(m['sort_order'])),
      isActive: Value(_b(m['is_active'])),
      createdAt: Value(_s(m['created_at'])),
      updatedAt: Value(_s(m['updated_at'])),
    );

PosProductsTableCompanion posProductFromMap(Map<String, dynamic> m) =>
    PosProductsTableCompanion(
      id: Value(_i(m['id'])!),
      hotelId: Value(_i(m['hotel_id'])),
      categoryId: Value(_i(m['category_id'])),
      name: Value(_s(m['name'])),
      description: Value(_s(m['description'])),
      imageUrl: Value(_s(m['image_url'])),
      sellPrice: Value(_i(m['sell_price'])),
      costPrice: Value(_i(m['cost_price'])),
      taxPercent: Value(_s(m['tax_percent'])),
      isAvailable: Value(_b(m['is_available'])),
      isFeatured: Value(_b(m['is_featured'])),
      trackStock: Value(_b(m['track_stock'])),
      inventoryItemId: Value(_i(m['inventory_item_id'])),
      sortOrder: Value(_i(m['sort_order'])),
      createdAt: Value(_s(m['created_at'])),
      updatedAt: Value(_s(m['updated_at'])),
    );

PosTablesTableCompanion posTableFromMap(Map<String, dynamic> m) =>
    PosTablesTableCompanion(
      id: Value(_i(m['id'])!),
      hotelId: Value(_i(m['hotel_id'])),
      name: Value(_s(m['name'])),
      capacity: Value(_i(m['capacity'])),
      floor: Value(_s(m['floor'])),
      status: Value(_s(m['status'])),
      currentOrderId: Value(_i(m['current_order_id'])),
      sortOrder: Value(_i(m['sort_order'])),
      isActive: Value(_b(m['is_active'])),
      createdAt: Value(_s(m['created_at'])),
      updatedAt: Value(_s(m['updated_at'])),
    );

PosShiftsTableCompanion posShiftFromMap(Map<String, dynamic> m) =>
    PosShiftsTableCompanion(
      id: Value(_i(m['id'])!),
      hotelId: Value(_i(m['hotel_id'])),
      openedBy: Value(_i(m['opened_by'])),
      closedBy: Value(_i(m['closed_by'])),
      openedAt: Value(_s(m['opened_at'])),
      closedAt: Value(_s(m['closed_at'])),
      openingCash: Value(_i(m['opening_cash'])),
      closingCash: Value(_i(m['closing_cash'])),
      expectedCash: Value(_i(m['expected_cash'])),
      cashVariance: Value(_i(m['cash_variance'])),
      totalSales: Value(_i(m['total_sales'])),
      totalVoids: Value(_i(m['total_voids'])),
      totalOrders: Value(_i(m['total_orders'])),
      notes: Value(_s(m['notes'])),
      status: Value(_s(m['status'])),
      createdAt: Value(_s(m['created_at'])),
    );

PosOrdersTableCompanion posOrderFromMap(Map<String, dynamic> m) =>
    PosOrdersTableCompanion(
      id: Value(_i(m['id'])!),
      hotelId: Value(_i(m['hotel_id'])),
      shiftId: Value(_i(m['shift_id'])),
      tableId: Value(_i(m['table_id'])),
      bookingId: Value(_i(m['booking_id'])),
      roomId: Value(_i(m['room_id'])),
      orderNumber: Value(_s(m['order_number'])),
      orderType: Value(_s(m['order_type'])),
      status: Value(_s(m['status'])),
      guestName: Value(_s(m['guest_name'])),
      guestCount: Value(_i(m['guest_count'])),
      waiterId: Value(_i(m['waiter_id'])),
      cashierId: Value(_i(m['cashier_id'])),
      subtotal: Value(_i(m['subtotal'])),
      taxAmount: Value(_i(m['tax_amount'])),
      discountAmount: Value(_i(m['discount_amount'])),
      total: Value(_i(m['total'])),
      notes: Value(_s(m['notes'])),
      voidReason: Value(_s(m['void_reason'])),
      voidedBy: Value(_i(m['voided_by'])),
      voidedAt: Value(_s(m['voided_at'])),
      kitchenSentAt: Value(_s(m['kitchen_sent_at'])),
      settledAt: Value(_s(m['settled_at'])),
      createdAt: Value(_s(m['created_at'])),
      updatedAt: Value(_s(m['updated_at'])),
    );

PosOrderItemsTableCompanion posOrderItemFromMap(Map<String, dynamic> m) =>
    PosOrderItemsTableCompanion(
      id: Value(_i(m['id'])!),
      orderId: Value(_i(m['order_id'])),
      productId: Value(_i(m['product_id'])),
      productName: Value(_s(m['product_name'])),
      unitPrice: Value(_i(m['unit_price'])),
      costPrice: Value(_i(m['cost_price'])),
      quantity: Value(_i(m['quantity'])),
      notes: Value(_s(m['notes'])),
      status: Value(_s(m['status'])),
      isVoided: Value(_b(m['is_voided'])),
      voidReason: Value(_s(m['void_reason'])),
      voidedBy: Value(_i(m['voided_by'])),
      voidedAt: Value(_s(m['voided_at'])),
      sentAt: Value(_s(m['sent_at'])),
      createdAt: Value(_s(m['created_at'])),
    );

PosPaymentsTableCompanion posPaymentFromMap(Map<String, dynamic> m) =>
    PosPaymentsTableCompanion(
      id: Value(_i(m['id'])!),
      orderId: Value(_i(m['order_id'])),
      shiftId: Value(_i(m['shift_id'])),
      method: Value(_s(m['method'])),
      amount: Value(_i(m['amount'])),
      reference: Value(_s(m['reference'])),
      receivedBy: Value(_i(m['received_by'])),
      createdAt: Value(_s(m['created_at'])),
    );

PosCashMovementsTableCompanion posCashMovementFromMap(
        Map<String, dynamic> m) =>
    PosCashMovementsTableCompanion(
      id: Value(_i(m['id'])!),
      shiftId: Value(_i(m['shift_id'])),
      hotelId: Value(_i(m['hotel_id'])),
      type: Value(_s(m['type'])),
      amount: Value(_i(m['amount'])),
      reason: Value(_s(m['reason'])),
      performedBy: Value(_i(m['performed_by'])),
      createdAt: Value(_s(m['created_at'])),
    );

PosRefundsTableCompanion posRefundFromMap(Map<String, dynamic> m) =>
    PosRefundsTableCompanion(
      id: Value(_i(m['id'])!),
      hotelId: Value(_i(m['hotel_id'])),
      orderId: Value(_i(m['order_id'])),
      shiftId: Value(_i(m['shift_id'])),
      amount: Value(_i(m['amount'])),
      method: Value(_s(m['method'])),
      reason: Value(_s(m['reason'])),
      reference: Value(_s(m['reference'])),
      refundedBy: Value(_i(m['refunded_by'])),
      createdAt: Value(_s(m['created_at'])),
    );

PosWastageLogsTableCompanion posWastageLogFromMap(Map<String, dynamic> m) =>
    PosWastageLogsTableCompanion(
      id: Value(_i(m['id'])!),
      hotelId: Value(_i(m['hotel_id'])),
      shiftId: Value(_i(m['shift_id'])),
      productId: Value(_i(m['product_id'])),
      productName: Value(_s(m['product_name'])),
      costPrice: Value(_i(m['cost_price'])),
      quantity: Value(_i(m['quantity'])),
      reason: Value(_s(m['reason'])),
      recordedBy: Value(_i(m['recorded_by'])),
      createdAt: Value(_s(m['created_at'])),
    );

// ─── Notifications & Audit ────────────────────────────────────────────────────

NotificationsTableCompanion notificationFromMap(Map<String, dynamic> m) =>
    NotificationsTableCompanion(
      id: Value(_i(m['id'])!),
      type: Value(_s(m['type'])),
      guestId: Value(_i(m['guest_id'])),
      userId: Value(_i(m['user_id'])),
      recipient: Value(_s(m['recipient'])),
      message: Value(_s(m['message'])),
      status: Value(_s(m['status'])),
      relatedEntityId: Value(_i(m['related_entity_id'])),
      entityType: Value(_s(m['entity_type'])),
      createdAt: Value(_s(m['created_at'])),
      updatedAt: Value(_s(m['updated_at'])),
    );

AuditLogsTableCompanion auditLogFromMap(Map<String, dynamic> m) =>
    AuditLogsTableCompanion(
      id: Value(_i(m['id'])!),
      action: Value(_s(m['action'])),
      userId: Value(_i(m['user_id'])),
      entityType: Value(_s(m['entity_type'])),
      entityId: Value(_i(m['entity_id'])),
      details: Value(_s(m['details'])),
      dataBefore: Value(_s(m['data_before'])),
      dataAfter: Value(_s(m['data_after'])),
      createdAt: Value(_s(m['created_at'])),
      updatedAt: Value(_s(m['updated_at'])),
    );
