// pages/day_book_history.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '/Model/transaction_models.dart';
import '/Service/transaction_service.dart';

class DayBookHistory extends StatefulWidget {
  const DayBookHistory({super.key});

  @override
  State<DayBookHistory> createState() => _DayBookHistoryState();
}

class _DayBookHistoryState extends State<DayBookHistory> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();

  final TransactionService _transactionService = TransactionService();
  final ValueNotifier<bool> _isLoading = ValueNotifier<bool>(false);
  final ValueNotifier<String> _errorMessage = ValueNotifier<String>('');

  List<Transaction> _allTransactions = [];
  List<Transaction> _filteredTransactions = [];

  // Ledger Column Widths
  static const double _colSrWidth = 50.0;
  static const double _colDateWidth = 100.0;
  static const double _colMobileWidth = 110.0;
  static const double _colParticularWidth = 220.0;
  static const double _colAmountWidth = 110.0;
  static const double _colTotalBalWidth = 130.0;
  static const double _colRemarksWidth = 200.0;
  static const double _colExpNoWidth = 100.0;
  static const double _colRecNoWidth = 100.0;
  static const double _colImgWidth = 60.0;
  static const double _colUserWidth = 100.0;
  static const double _colActionWidth = 100.0;

  double get _totalTableWidth =>
      _colSrWidth + _colDateWidth + _colMobileWidth + _colParticularWidth +
          (_colAmountWidth * 2) + _colTotalBalWidth + _colRemarksWidth +
          _colExpNoWidth + _colRecNoWidth + _colImgWidth + _colUserWidth + _colActionWidth;
  TransactionResponse? _transactionResponse; // Store full response to access DayBookData
  String? _selectedFilter; // null means "All" - no filtering
  DateTimeRange? _currentDateRange; // null means show all records

  @override
  void initState() {
    super.initState();
    _initializeData();
    _searchController.addListener(_filterTransactions);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterTransactions);
    _searchController.dispose();
    _horizontalScrollController.dispose();
    _verticalScrollController.dispose();
    _isLoading.dispose();
    _errorMessage.dispose();
    super.dispose();
  }

  void _initializeData() {
    // Default: Show all records without filtering
    _currentDateRange = null;
    _loadTransactions();
  }

  Future<void> _loadTransactions({bool forceRefresh = false}) async {
    _isLoading.value = true;
    _errorMessage.value = '';

    try {
      final response = await _transactionService.getTransactions(
        fromDate: _currentDateRange?.start,
        toDate: _currentDateRange?.end,
        forceRefresh: forceRefresh,
      );

      final allTransactions = response.getAllTransactions();

      // Apply client-side date filtering only if a filter is selected
      final filteredByDate = _currentDateRange != null
          ? _filterTransactionsByDateRange(allTransactions, _currentDateRange!)
          : allTransactions; // Show all if no filter selected

      if (mounted) {
        setState(() {
          _transactionResponse = response; // Store full response for balance access
          _allTransactions = filteredByDate;
          _filteredTransactions = filteredByDate;
        });
      }
    } catch (e) {
      _errorMessage.value = e.toString();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      _isLoading.value = false;
    }
  }

  /// Gets the date range for the specified filter
  ///
  /// - Today: Only today's date
  /// - Weekly: Current week (Monday to Sunday)
  /// - Monthly: Current month only (from start of month to today)
  /// Returns null for "All" to show all records
  DateTimeRange? _getDateRangeForFilter(String? filter) {
    if (filter == null) return null; // Show all records

    final now = DateTime.now();
    final todayStart = _getStartOfDay(now);
    final todayEnd = _getEndOfDay(now);

    switch (filter) {
      case 'Today':
        return DateTimeRange(start: todayStart, end: todayEnd);

      case 'Weekly':
      // Current week: Monday to Sunday (or today if today is before Sunday)
        final daysFromMonday = now.weekday - 1; // Monday = 0, Sunday = 6
        final startOfWeek = todayStart.subtract(Duration(days: daysFromMonday));
        final endOfWeekDate = startOfWeek.add(const Duration(days: 6));
        // Use today if it's before the end of the week, otherwise use end of week
        final endDate = endOfWeekDate.isAfter(now) ? now : endOfWeekDate;
        return DateTimeRange(start: startOfWeek, end: _getEndOfDay(endDate));

      case 'Monthly':
      // Current month only (from start of month to today)
        final startOfMonth = DateTime(now.year, now.month, 1);
        return DateTimeRange(start: startOfMonth, end: todayEnd);

      default:
        return null; // Show all records
    }
  }

  /// Returns the start of the day (00:00:00) for the given date
  DateTime _getStartOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Returns the end of the day (23:59:59) for the given date
  DateTime _getEndOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59);
  }

  /// Filters transactions by date range to ensure they match the selected filter
  /// This provides client-side filtering to ensure accuracy regardless of API response
  List<Transaction> _filterTransactionsByDateRange(
      List<Transaction> transactions,
      DateTimeRange dateRange,
      ) {
    final rangeStart = dateRange.start;
    final rangeEnd = dateRange.end;

    return transactions.where((transaction) {
      try {
        final transactionDate = DateTime.parse(transaction.createdDateTime);

        // Check if transaction date falls within the range (inclusive on both ends)
        // rangeStart <= transactionDate <= rangeEnd
        return !transactionDate.isBefore(rangeStart) &&
            !transactionDate.isAfter(rangeEnd);
      } catch (e) {
        // If date parsing fails, exclude the transaction
        return false;
      }
    }).toList();
  }

  /// Filters transactions based on search query
  /// Searches across: mobile number, particular name, remarks, voucher numbers, and transaction flag
  void _filterTransactions() {
    final query = _searchController.text.toLowerCase().trim();

    setState(() {
      if (query.isEmpty) {
        _filteredTransactions = List.from(_allTransactions);
      } else {
        _filteredTransactions = _allTransactions
            .where(_matchesSearchQuery(query))
            .toList();
      }
    });
  }

  /// Returns a predicate function that checks if a transaction matches the search query
  bool Function(Transaction) _matchesSearchQuery(String query) {
    return (Transaction transaction) {
      return _containsIgnoreCase(transaction.mobileNo, query) ||
          _containsIgnoreCase(transaction.particularName, query) ||
          _containsIgnoreCase(transaction.remarks, query) ||
          _containsIgnoreCase(transaction.receiptBowcherNo, query) ||
          _containsIgnoreCase(transaction.expenseBowcherNo, query) ||
          _containsIgnoreCase(transaction.flag, query);
    };
  }

  /// Helper method to safely check if a string contains a query (case-insensitive)
  bool _containsIgnoreCase(String? text, String query) {
    if (text == null || text.isEmpty) return false;
    return text.toLowerCase().contains(query);
  }

  /// Handles filter change and automatically refreshes the transaction list
  void _handleFilterChange(String? filter) {
    if (_selectedFilter == filter) return; // Avoid unnecessary reloads

    setState(() {
      _selectedFilter = filter;
      _currentDateRange = _getDateRangeForFilter(filter);
    });

    // Clear search when filter changes
    _searchController.clear();

    // Reload transactions with new date range
    _loadTransactions(forceRefresh: true);
  }

  /// Calculates total debit and credit amounts from a list of transactions
  ({double debit, double credit}) _calculateTotals(
      List<Transaction> transactions,
      ) {
    double totalDebit = 0.0;
    double totalCredit = 0.0;

    for (final transaction in transactions) {
      if (transaction.debit != null) {
        totalDebit += transaction.amount;
      } else if (transaction.credit != null) {
        totalCredit += transaction.amount;
      }
    }

    return (debit: totalDebit, credit: totalCredit);
  }

  /// Gets opening balance and next day final balance from DayBookData
  /// For "Today" filter: returns today's balances
  /// For other filters: returns the most recent day's balances
  /// Returns null if no data available
  ({double todayOpeningBalance, double nextDayFinalBalance})? _getTodayBalances() {
    if (_transactionResponse == null || _transactionResponse!.data.isEmpty) {
      return null;
    }

    final now = DateTime.now();
    DayBookData? targetDayData;

    // For "Today" filter, find today's DayBookData
    if (_selectedFilter == 'Today') {
      final todayDateStr = DateFormat('yyyy-MM-dd').format(now);

      for (final dayData in _transactionResponse!.data) {
        if (_isSameDay(dayData.date, now)) {
          targetDayData = dayData;
          break;
        }
      }
    } else {
      // For other filters or "All", get the most recent day's data
      // Find the day that matches the current date range or get the latest
      if (_currentDateRange != null) {
        // Find the day within the date range
        for (final dayData in _transactionResponse!.data) {
          if (_isDateInRange(dayData.date, _currentDateRange!)) {
            targetDayData = dayData;
            break;
          }
        }
      }

      // If no match found or "All" filter, use the first (most recent) day
      if (targetDayData == null && _transactionResponse!.data.isNotEmpty) {
        targetDayData = _transactionResponse!.data.first;
      }
    }

    if (targetDayData != null) {
      return (
      todayOpeningBalance: targetDayData.todayOpeningBalance,
      nextDayFinalBalance: targetDayData.nextDayFinalBalance,
      );
    }

    return null;
  }

  /// Helper to check if a date string matches a specific date
  bool _isSameDay(String dateString, DateTime date) {
    try {
      // Try parsing the date string
      DateTime parsedDate;
      if (dateString.contains('T')) {
        parsedDate = DateTime.parse(dateString);
      } else {
        // Try different date formats
        parsedDate = DateFormat('yyyy-MM-dd').parse(dateString);
      }

      return parsedDate.year == date.year &&
          parsedDate.month == date.month &&
          parsedDate.day == date.day;
    } catch (e) {
      // Try string matching as fallback
      final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      return dateString.contains(dateStr);
    }
  }

  /// Helper to check if a date string falls within a date range
  bool _isDateInRange(String dateString, DateTimeRange range) {
    try {
      DateTime parsedDate;
      if (dateString.contains('T')) {
        parsedDate = DateTime.parse(dateString);
      } else {
        parsedDate = DateFormat('yyyy-MM-dd').parse(dateString);
      }

      // Compare only the date part (ignore time)
      final dateOnly = DateTime(parsedDate.year, parsedDate.month, parsedDate.day);
      final rangeStart = DateTime(range.start.year, range.start.month, range.start.day);
      final rangeEnd = DateTime(range.end.year, range.end.month, range.end.day);

      return !dateOnly.isBefore(rangeStart) && !dateOnly.isAfter(rangeEnd);
    } catch (e) {
      return false;
    }
  }

  String _formatCurrency(double amount) {
    return '₹${NumberFormat('#,##0.00').format(amount)}';
  }

  String _formatDateTime(String dateTimeString) {
    try {
      final DateTime dateTime = DateTime.parse(dateTimeString);
      return DateFormat('dd-MMM-yyyy HH:mm').format(dateTime);
    } catch (e) {
      return dateTimeString;
    }
  }

  String _formatShortDate(String dateTimeString) {
    try {
      final DateTime dateTime = DateTime.parse(dateTimeString);
      return DateFormat('dd/MMM').format(dateTime);
    } catch (e) {
      return dateTimeString;
    }
  }

  String _formatTime(String dateTimeString) {
    try {
      final DateTime dateTime = DateTime.parse(dateTimeString);
      return DateFormat('HH:mm').format(dateTime);
    } catch (e) {
      return dateTimeString;
    }
  }

  String _formatLongDate(String dateString) {
    try {
      DateTime dateTime;
      if (dateString.contains('T')) {
        dateTime = DateTime.parse(dateString);
      } else {
        // Handle common formats or simplified date strings
        dateTime = DateFormat('yyyy-MM-dd').parse(dateString);
      }
      return DateFormat('dd-MMM-yyyy').format(dateTime);
    } catch (e) {
      return dateString;
    }
  }

  void _handleViewDetails(Transaction transaction) {
    showDialog(
      context: context,
      builder: (context) => TransactionDetailDialog(transaction: transaction),
    );
  }

  void _handleViewImage(Transaction transaction) {
    if (transaction.hasImage) {
      showDialog(
        context: context,
        builder: (context) => ImageViewDialog(imageUrl: transaction.imageUrl),
      );
    }
  }

  void _handleRefresh() {
    _loadTransactions(forceRefresh: true);
  }

  Color _getAmountColor(String flag) {
    return flag == 'Debit' ? Colors.red[700]! : Colors.green[700]!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Day Book History'),
        backgroundColor: Colors.blue[900],
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          ValueListenableBuilder<bool>(
            valueListenable: _isLoading,
            builder: (context, isLoading, child) {
              return isLoading
                  ? const Padding(
                padding: EdgeInsets.all(8.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.white,
                    ),
                  ),
                ),
              )
                  : IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _handleRefresh,
                tooltip: 'Refresh',
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Header with filter and search
          _buildHeaderSection(),

          // Results Count and Summary
          _buildSummarySection(),

          const SizedBox(height: 8),

          // Content Area
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Filter Section
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Filter by Period',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildFilterButton(null, Icons.list, 'All'),
                  const SizedBox(width: 8),
                  _buildFilterButton('Today', Icons.today),
                  const SizedBox(width: 8),
                  _buildFilterButton('Weekly', Icons.calendar_view_week),
                  const SizedBox(width: 8),
                  _buildFilterButton('Monthly', Icons.calendar_today),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Search Box
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          _searchController.clear();
                          _filterTransactions();
                        },
                      )
                          : null,
                      hintText: "Search by name, voucher, or remarks...",
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                    onChanged: (value) => _filterTransactions(),
                  ),
                ),
                ValueListenableBuilder<String>(
                  valueListenable: _errorMessage,
                  builder: (context, errorMessage, child) {
                    return errorMessage.isNotEmpty
                        ? IconButton(
                      icon: Icon(Icons.error_outline,
                          color: Colors.red[700]),
                      onPressed: () => _errorMessage.value = '',
                    )
                        : const SizedBox();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String? filter, IconData icon, [String? label]) {
    final isSelected = _selectedFilter == filter;
    final displayLabel = label ?? filter ?? 'All';

    return Expanded(
      child: GestureDetector(
        onTap: () => _handleFilterChange(filter),
        child: Container(
          height: 40,
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue[900]! : Colors.grey[100],
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isSelected ? Colors.blue[900]! : Colors.grey[300]!,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : Colors.grey[600],
              ),
              const SizedBox(width: 6),
              Text(
                displayLabel,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummarySection() {
    return ValueListenableBuilder<bool>(
      valueListenable: _isLoading,
      builder: (context, isLoading, child) {
        if (isLoading || _allTransactions.isEmpty) return const SizedBox();

        final totals = _calculateTotals(_allTransactions);
        final balances = _getTodayBalances();

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: Colors.white,
          child: Wrap(
            spacing: 8,
            runSpacing: 6,
            alignment: WrapAlignment.start,
            children: [
              // Debit and Credit totals
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Debit: ${_formatCurrency(totals.debit)}',
                  style: TextStyle(
                    color: Colors.red[700],
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Credit: ${_formatCurrency(totals.credit)}',
                  style: TextStyle(
                    color: Colors.green[700],
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              // Today Opening Balance
              if (balances != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Opening: ${_formatCurrency(balances.todayOpeningBalance)}',
                    style: TextStyle(
                      color: Colors.blue[700],
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              // Next Day Final Balance
              if (balances != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Closing: ${_formatCurrency(balances.nextDayFinalBalance)}',
                    style: TextStyle(
                      color: Colors.orange[700],
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContent() {
    return ValueListenableBuilder<bool>(
      valueListenable: _isLoading,
      builder: (context, isLoading, child) {
        if (isLoading) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading transactions...'),
              ],
            ),
          );
        }

        return ValueListenableBuilder<String>(
          valueListenable: _errorMessage,
          builder: (context, errorMessage, child) {
            if (errorMessage.isNotEmpty && _allTransactions.isEmpty) {
              return _buildErrorState();
            }

            if (_filteredTransactions.isEmpty) {
              return _buildEmptyState();
            }

            return _buildLedgerView();
          },
        );
      },
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
            const SizedBox(height: 16),
            const Text(
              'Failed to load transactions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage.value,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _handleRefresh,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[900],
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            _searchController.text.isEmpty
                ? 'No transactions available'
                : 'No transactions found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          if (_searchController.text.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search criteria',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLedgerView() {
    return Column(
      children: [
        // Horizontal Header (Fixed at top)
        SingleChildScrollView(
          controller: _horizontalScrollController,
          scrollDirection: Axis.horizontal,
          child: _buildTableHeader(),
        ),

        // Scrollable Table Body
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async => _handleRefresh(),
            child: SingleChildScrollView(
              controller: _verticalScrollController,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                // Synced with header manually or by sharing the same controller if needed
                // But header logic usually needs to stay in sync.
                // We'll use the same ScrollController for both horizontal scrolls.
                controller: _horizontalScrollController,
                child: _buildTableBody(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTableHeader() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.lightBlue[100],
        border: Border.all(color: Colors.grey[400]!),
      ),
      child: Row(
        children: [
          _buildHeaderCell('Sr No', _colSrWidth),
          _buildHeaderCell('DateTime', _colDateWidth),
          _buildHeaderCell('Mobile No', _colMobileWidth),
          _buildHeaderCell('ParticularName', _colParticularWidth),
          _buildHeaderCell('Debit', _colAmountWidth),
          _buildHeaderCell('Credit', _colAmountWidth),
          _buildHeaderCell('Total Balance', _colTotalBalWidth),
          _buildHeaderCell('Remarks', _colRemarksWidth),
          _buildHeaderCell('ExpensBouNo', _colExpNoWidth),
          _buildHeaderCell('ReciptBouNo', _colRecNoWidth),
          _buildHeaderCell('Image', _colImgWidth),
          _buildHeaderCell('CreatedBy', _colUserWidth),
          _buildHeaderCell('Action', _colActionWidth),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String label, double width) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
      decoration: BoxDecoration(
        border: Border(right: BorderSide(color: Colors.grey[400]!)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
          color: Colors.black,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildTableBody() {
    if (_searchController.text.isNotEmpty) {
      return Column(
        children: [
          for (int i = 0; i < _filteredTransactions.length; i++)
            _buildDataRow(i + 1, _filteredTransactions[i]),
        ],
      );
    }

    if (_transactionResponse == null) return const SizedBox();

    List<Widget> rows = [];
    int globalSrNo = 1;

    for (var dayData in _transactionResponse!.data) {
      rows.add(_buildDateGroupRow(dayData));
      for (var tx in dayData.transactions) {
        rows.add(_buildDataRow(globalSrNo++, tx));
      }
      rows.add(_buildDaySummaryRows(dayData));
    }

    return Column(children: rows);
  }

  Widget _buildDateGroupRow(DayBookData dayData) {
    return Container(
      width: _totalTableWidth,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD), // Subtle blue
        border: Border(
          bottom: BorderSide(color: Colors.grey[400]!),
          left: BorderSide(color: Colors.grey[400]!),
          right: BorderSide(color: Colors.grey[400]!),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_today, size: 14, color: Colors.blue),
          const SizedBox(width: 8),
          Text(
            'Date: ${_formatLongDate(dayData.date)}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(width: 30),
          const Icon(Icons.account_balance, size: 14, color: Colors.green),
          const SizedBox(width: 8),
          Text(
            'Opening Balance: ',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey[700]),
          ),
          Text(
            _formatCurrency(dayData.todayOpeningBalance),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataRow(int srNo, Transaction tx) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!),
          left: BorderSide(color: Colors.grey[400]!),
          right: BorderSide(color: Colors.grey[400]!),
        ),
      ),
      child: Row(
        children: [
          _buildDataCell('$srNo', _colSrWidth, textAlign: TextAlign.center),
          _buildDataCell(_formatShortDate(tx.createdDateTime), _colDateWidth, textAlign: TextAlign.center),
          _buildDataCell(tx.mobileNo ?? '-', _colMobileWidth, textAlign: TextAlign.center, textColor: Colors.blue[800]),
          _buildParticularCell(tx),
          _buildAmountCell(tx.debit, _colAmountWidth, Colors.red[700]!),
          _buildAmountCell(tx.credit, _colAmountWidth, Colors.green[700]!),
          _buildDataCell(_formatCurrency(tx.totalBalance ?? 0), _colTotalBalWidth, textAlign: TextAlign.right, isBold: true),
          _buildRemarksCell(tx),
          _buildDataCell(tx.expenseBowcherNo ?? 'NO', _colExpNoWidth, textAlign: TextAlign.center),
          _buildDataCell(tx.receiptBowcherNo ?? 'NO', _colRecNoWidth, textAlign: TextAlign.center),
          _buildImageCell(tx),
          _buildDataCell('Admin', _colUserWidth, textAlign: TextAlign.center),
          _buildActionCell(tx),
        ],
      ),
    );
  }

  Widget _buildDaySummaryRows(DayBookData dayData) {
    return Column(
      children: [
        // Total row
        Container(
          width: _totalTableWidth,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            border: Border(
              bottom: BorderSide(color: Colors.grey[400]!),
              left: BorderSide(color: Colors.grey[400]!),
              right: BorderSide(color: Colors.grey[400]!),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: _colSrWidth + _colDateWidth + _colMobileWidth + _colParticularWidth,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                alignment: Alignment.centerRight,
                child: Text(
                  'Total (for ${_formatLongDate(dayData.date)})',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
              _buildDataCell(_formatCurrency(dayData.totalDebit), _colAmountWidth, textAlign: TextAlign.right, isBold: true),
              _buildDataCell(_formatCurrency(dayData.totalCredit), _colAmountWidth, textAlign: TextAlign.right, isBold: true),
              Container(width: _totalTableWidth - (_colSrWidth + _colDateWidth + _colMobileWidth + _colParticularWidth + _colAmountWidth * 2)),
            ],
          ),
        ),
        // Final Balance row
        Container(
          width: _totalTableWidth,
          decoration: BoxDecoration(
            color: const Color(0xFFFFF9C4), // Light orange/yellow
            border: Border(
              bottom: BorderSide(color: Colors.grey[400]!),
              left: BorderSide(color: Colors.grey[400]!),
              right: BorderSide(color: Colors.grey[400]!),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: _colSrWidth + _colDateWidth + _colMobileWidth + _colParticularWidth + _colAmountWidth * 2,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                alignment: Alignment.centerRight,
                child: const Text(
                  'Final Balance (Carry Forward to Next Day)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
              _buildDataCell(_formatCurrency(dayData.nextDayFinalBalance), _colTotalBalWidth, textAlign: TextAlign.right, isBold: true),
              Container(width: _totalTableWidth - (_colSrWidth + _colDateWidth + _colMobileWidth + _colParticularWidth + _colAmountWidth * 2 + _colTotalBalWidth)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDataCell(String text, double width, {TextAlign textAlign = TextAlign.start, bool isBold = false, Color? textColor}) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        border: Border(right: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          color: textColor ?? Colors.black87,
        ),
        textAlign: textAlign,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildParticularCell(Transaction tx) {
    return Container(
      width: _colParticularWidth,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        border: Border(right: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              tx.particularName,
              style: TextStyle(fontSize: 12, color: Colors.grey[800]),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 4),
          InkWell(
            onTap: () => _handleViewDetails(tx),
            child: const Text(
              'Show',
              style: TextStyle(fontSize: 11, color: Colors.blue, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountCell(double? amount, double width, Color color) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        border: Border(right: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Text(
        amount != null && amount > 0 ? _formatCurrency(amount) : '',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: color,
        ),
        textAlign: TextAlign.right,
      ),
    );
  }

  Widget _buildRemarksCell(Transaction tx) {
    return Container(
      width: _colRemarksWidth,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        border: Border(right: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              tx.remarks ?? tx.remark ?? '-',
              style: const TextStyle(fontSize: 11),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 4),
          InkWell(
            onTap: () => _handleViewDetails(tx),
            child: const Text(
              'Show',
              style: TextStyle(fontSize: 11, color: Colors.blue),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageCell(Transaction tx) {
    return Container(
      width: _colImgWidth,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border(right: BorderSide(color: Colors.grey[300]!)),
      ),
      child: tx.hasImage
          ? IconButton(
        icon: const Icon(Icons.image_outlined, size: 20, color: Colors.blue),
        onPressed: () => _handleViewImage(tx),
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
      )
          : const Text('No', style: TextStyle(fontSize: 10, color: Colors.red)),
    );
  }

  Widget _buildActionCell(Transaction tx) {
    return Container(
      width: _colActionWidth,
      alignment: Alignment.center,
      child: ElevatedButton(
        onPressed: () => _handleViewDetails(tx),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue[800],
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          minimumSize: const Size(70, 32),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Actions', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
            Icon(Icons.arrow_drop_down, size: 14),
          ],
        ),
      ),
    );
  }
}

// Image View Dialog
class ImageViewDialog extends StatelessWidget {
  final String imageUrl;

  const ImageViewDialog({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Stack(
        children: [
          Container(
            constraints: const BoxConstraints(maxWidth: 500, maxHeight: 500),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.contain,
                placeholder: (context, url) => Container(
                  color: Colors.grey[200],
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[200],
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, color: Colors.red, size: 48),
                      SizedBox(height: 8),
                      Text('Failed to load image'),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: CircleAvatar(
              backgroundColor: Colors.black54,
              radius: 16,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 16),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Transaction Detail Dialog
class TransactionDetailDialog extends StatelessWidget {
  final Transaction transaction;

  const TransactionDetailDialog({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16), // ✅ mobile safe margin
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxHeight: 650, // ✅ prevents overflow on small phones
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.receipt_long,
                        color: Colors.blue[900],
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Transaction Details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Details Grid
                _buildDetailGrid(context),


                const SizedBox(height: 20),

                // Remarks Section
                if (transaction.remarks != null &&
                    transaction.remarks!.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Remarks',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Text(
                          transaction.remarks!,
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ),
                    ],
                  ),

                if (transaction.hasImage) ...[
                  const SizedBox(height: 20),
                  const Text(
                    'Attached Image',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                      showDialog(
                        context: context,
                        builder: (context) =>
                            ImageViewDialog(imageUrl: transaction.imageUrl),
                      );
                    },
                    child: Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                          imageUrl: transaction.imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) =>
                          const Center(child: CircularProgressIndicator()),
                          errorWidget: (context, url, error) =>
                          const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.error_outline, color: Colors.grey),
                                SizedBox(height: 4),
                                Text('Failed to load image'),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 20),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                        label: const Text('Close'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (transaction.hasImage)
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).pop();
                            showDialog(
                              context: context,
                              builder: (context) =>
                                  ImageViewDialog(imageUrl: transaction.imageUrl),
                            );
                          },
                          icon: const Icon(Icons.image),
                          label: const Text('View Image'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[900],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildDetailGrid(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 360;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _detailItems().map((item) {
            return SizedBox(
              width: isSmallScreen
                  ? constraints.maxWidth
                  : (constraints.maxWidth / 2) - 6,
              child: _buildDetailItem(item.$1, item.$2),
            );
          }).toList(),
        );
      },
    );
  }


  List<(String, String)> _detailItems() {
    return [
      ('Date', _formatDateTime(transaction.createdDateTime)),
      ('Mobile', transaction.mobileNo ?? 'N/A'),
      ('Particular', transaction.particularName),
      ('Type', transaction.flag),
      ('Amount', _formatCurrency(transaction.amount)),
      if (transaction.debit != null)
        ('Debit', _formatCurrency(transaction.debit!)),
      if (transaction.credit != null)
        ('Credit', _formatCurrency(transaction.credit!)),
      if (transaction.totalBalance != null)
        ('Balance', _formatCurrency(transaction.totalBalance!)),
      ('Receipt No.', transaction.receiptBowcherNo ?? 'N/A'),
      ('Expense No.', transaction.expenseBowcherNo ?? 'N/A'),
      if (transaction.remark != null && transaction.remark!.isNotEmpty)
        ('Remark', transaction.remark!),
    ];
  }



  Widget _buildDetailItem(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            softWrap: true,
          ),
        ],
      ),
    );
  }




  String _formatCurrency(double amount) {
    return '₹${NumberFormat('#,##0.00').format(amount)}';
  }

  String _formatDateTime(String dateTimeString) {
    try {
      final DateTime dateTime = DateTime.parse(dateTimeString);
      return DateFormat('dd-MMM-yyyy, HH:mm').format(dateTime);
    } catch (e) {
      return dateTimeString;
    }
  }
}