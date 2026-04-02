import 'dart:convert';
import 'package:coopengageplus/core/network/network_handler.dart';
import 'package:coopengageplus/core/constants/kconstant.dart';
import 'package:coopengageplus/features/onboarding/pages/userInfoList/ViewCustomerInfoPage.dart';
import 'package:coopengageplus/features/onboarding/Update_IndividualAccount%20-/screens/registration_screen.dart';
import 'package:coopengageplus/features/onboarding/pages/userInfoList/OrganizationDetailPage.dart';
import 'package:coopengageplus/features/onboarding/pages/userInfoList/JointAccountDetailPage.dart';
import 'package:coopengageplus/features/onboarding/pages/verifyCustomerInfo.dart';
import 'package:coopengageplus/core/database/database_helper.dart';
import 'package:coopengageplus/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class UserListPage extends StatefulWidget {
  final String title;

  const UserListPage({Key? key, required this.title}) : super(key: key);

  @override
  _UserInfoPageState createState() => _UserInfoPageState();
}

enum SampleItem { view, verify }

class _UserInfoPageState extends State<UserListPage> {
  final NetworkHandler networkHandler = NetworkHandler();
  List<dynamic> users = [];
  List<dynamic> filteredUsers = [];
  bool isLoading1 = false;
  String searchQuery = '';

  SampleItem? selectedItem;
  int? userId;

  final List<String> customerTypes = ['INDIVIDUAL', 'JOINT', 'ORGANIZATION'];
  String selectedCustomerType = 'INDIVIDUAL';

  Map<String, List<String>> titleStatusMapping = isOnline
      ? {
          "New Applicants": ["INITIAL", "REGISTERED"],
          "Awaiting Action": [
            "PENDING",
            "UNAUTHORIZED",
            "AUTHORIZED",
            "UNSETTLED"
          ],
          "Approved": ["APPROVED"],
          "Rejected": ["REJECTED"],
        }
      : {
          "New Applicants": ["INITIAL"],
          "Awaiting Action": ["UNSETTLED"],
          "Approved": ["APPROVED"],
          "Rejected": ["REJECTED"],
        };

  List<String> dropdownOptions = [];
  String? selectedCategory;

  @override
  void initState() {
    super.initState();
    _fetchToken();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        SystemChrome.setSystemUIOverlayStyle(systemUiForCyanAppBar);
      }
    });
    dropdownOptions = titleStatusMapping[widget.title] ?? [];
    if (dropdownOptions.isNotEmpty) {
      selectedCategory = dropdownOptions[0];
      fetchUsers(selectedCategory!);
    }
  }

  @override
  void dispose() {
    SystemChrome.setSystemUIOverlayStyle(systemUiForLightBackground);
    super.dispose();
  }

  IconData _getStatusIcon(String status) {
    switch (status.toUpperCase()) {
      case 'APPROVED':
        return Icons.check_circle_outline;
      case 'PENDING':
        return Icons.schedule;
      case 'REJECTED':
        return Icons.cancel_outlined;
      case 'INITIAL':
        return Icons.fiber_new_outlined;
      case 'REGISTERED':
        return Icons.how_to_reg_outlined;
      case 'UNAUTHORIZED':
        return Icons.lock_outline;
      case 'AUTHORIZED':
        return Icons.verified_user_outlined;
      case 'UNSETTLED':
        return Icons.pending_actions_outlined;
      default:
        return Icons.help_outline;
    }
  }

  IconData _getCustomerTypeIcon(String type) {
    switch (type) {
      case 'INDIVIDUAL':
        return Icons.person_outline;
      case 'JOINT':
        return Icons.people_outline;
      case 'ORGANIZATION':
        return Icons.business_outlined;
      default:
        return Icons.person_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildFiltersSection(),
          _buildSearchBar(),
          const SizedBox(height: 4),
          _buildResultsHeader(),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: cyanblueColor,
      systemOverlayStyle: systemUiForCyanAppBar,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, size: 20, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        widget.title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          letterSpacing: 0.3,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white),
          onPressed: () {
            if (selectedCategory != null) fetchUsers(selectedCategory!);
          },
        ),
      ],
    );
  }

  Widget _buildFiltersSection() {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          if (isOnline) _buildCustomerTypeSegment(),
          if (dropdownOptions.isNotEmpty) _buildStatusChips(),
          const Divider(height: 1, color: Color(0xFFE0E0E0)),
        ],
      ),
    );
  }

  Widget _buildCustomerTypeSegment() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF0F2F5),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(3),
        child: Row(
          children: customerTypes.map((type) {
            final isSelected = selectedCustomerType == type;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    selectedCustomerType = type;
                    if (selectedCategory != null) fetchUsers(selectedCategory!);
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? cyanblueColor : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: cyanblueColor.withOpacity(0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            )
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _getCustomerTypeIcon(type),
                        size: 16,
                        color: isSelected ? Colors.white : Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        type[0] + type.substring(1).toLowerCase(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected ? Colors.white : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildStatusChips() {
    return SizedBox(
      height: 52,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: dropdownOptions.length,
        itemBuilder: (context, index) {
          final status = dropdownOptions[index];
          final isSelected = selectedCategory == status;
          final color = cyanblueColor;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              selected: isSelected,
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getStatusIcon(status),
                    size: 14,
                    color: isSelected ? Colors.white : color,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    status[0] + status.substring(1).toLowerCase(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : color,
                    ),
                  ),
                ],
              ),
              backgroundColor: color.withOpacity(0.08),
              selectedColor: color,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? color : color.withOpacity(0.3),
                  width: 1,
                ),
              ),
              showCheckmark: false,
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              onSelected: (_) {
                setState(() {
                  selectedCategory = status;
                  fetchUsers(status);
                });
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextFormField(
          decoration: InputDecoration(
            hintText: 'Search by name...',
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
            prefixIcon:
                Icon(Icons.search, color: Colors.grey[400], size: 20),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
          onChanged: (value) {
            setState(() {
              searchQuery = value;
              filterUsers();
            });
          },
        ),
      ),
    );
  }

  Widget _buildResultsHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${filteredUsers.length} ${filteredUsers.length == 1 ? 'result' : 'results'}',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          if (selectedCategory != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: cyanblueColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                selectedCategory!,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: cyanblueColor,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading1) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(cyanblueColor),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Loading...',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    if (selectedCustomerType == 'ORGANIZATION') {
      return _buildOrganizationList();
    } else if (selectedCustomerType == 'JOINT') {
      return _buildJointAccountList();
    } else {
      return _buildIndividualList();
    }
  }

  Widget _buildEmptyState({required IconData icon, required String message}) {
    return Align(
      alignment: Alignment.topCenter,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(40, 24, 40, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: cyanblueColor.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40, color: cyanblueColor.withOpacity(0.4)),
            ),
            const SizedBox(height: 20),
            Text(
              message,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your filters or search query',
              style: TextStyle(fontSize: 13, color: Colors.grey[400]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ─── Individual List ───

  Widget _buildIndividualList() {
    if (filteredUsers.isEmpty) {
      return _buildEmptyState(
        icon: Icons.person_off_outlined,
        message: 'No individual accounts found',
      );
    }

    return RefreshIndicator(
      color: cyanblueColor,
      onRefresh: () async {
        if (selectedCategory != null) await fetchUsers(selectedCategory!);
      },
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        itemCount: filteredUsers.length,
        itemBuilder: (context, index) {
          final user = filteredUsers[index];
          return _buildIndividualCard(user, index);
        },
      ),
    );
  }

  Widget _buildIndividualCard(Map<String, dynamic> user, int index) {
    final String fullName = user['fullName'] ?? 'Unknown';
    final String phone = user['phone'] ?? '';
    final String email = user['email'] ?? '';
    final String status = user['status'] ?? selectedCategory ?? '';
    final String? branch = user['branch'];
    final String initials = fullName.isNotEmpty
        ? fullName.split(' ').map((w) => w.isNotEmpty ? w[0] : '').take(2).join().toUpperCase()
        : '?';

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        elevation: 1,
        shadowColor: Colors.black.withOpacity(0.08),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ViewCustomerInfo(
                  registrationData: user,
                  title: widget.title,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [cyanblueColor, cyanblueColor.withOpacity(0.7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      initials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fullName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A2E),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (phone.isNotEmpty) ...[
                            Icon(Icons.phone_outlined,
                                size: 13, color: Colors.grey[500]),
                            const SizedBox(width: 3),
                            Text(
                              phone,
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey[600]),
                            ),
                          ],
                          if (phone.isNotEmpty && email.isNotEmpty)
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 6),
                              child: Container(
                                width: 3,
                                height: 3,
                                decoration: BoxDecoration(
                                  color: Colors.grey[400],
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          if (email.isNotEmpty)
                            Expanded(
                              child: Row(
                                children: [
                                  Icon(Icons.email_outlined,
                                      size: 13, color: Colors.grey[500]),
                                  const SizedBox(width: 3),
                                  Expanded(
                                    child: Text(
                                      email,
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600]),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      if (branch != null && branch.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Icon(Icons.location_on_outlined,
                                size: 13, color: Colors.grey[500]),
                            const SizedBox(width: 3),
                            Text(
                              branch,
                              style: TextStyle(
                                  fontSize: 11, color: Colors.grey[500]),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (status.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: cyanblueColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          status[0] + status.substring(1).toLowerCase(),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: cyanblueColor,
                          ),
                        ),
                      ),
                    const SizedBox(height: 8),
                    _buildActionMenu(user),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionMenu(Map<String, dynamic> user) {
    return PopupMenuButton<SampleItem>(
      onSelected: (SampleItem item) {
        if (item == SampleItem.view) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ViewCustomerInfo(
                registrationData: user,
                title: widget.title,
              ),
            ),
          );
        } else if (item == SampleItem.verify) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Verifycustomerinfo(
                registrationData: user,
                title: widget.title,
              ),
            ),
          );
        }
      },
      icon: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(Icons.more_horiz, size: 18, color: Colors.grey[600]),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      itemBuilder: (BuildContext context) => <PopupMenuEntry<SampleItem>>[
        PopupMenuItem<SampleItem>(
          value: SampleItem.view,
          child: Row(
            children: [
              Icon(Icons.visibility_outlined, size: 18, color: cyanblueColor),
              const SizedBox(width: 10),
              const Text('View Details',
                  style: TextStyle(fontWeight: FontWeight.w500)),
            ],
          ),
        ),
        if (isOnline &&
            widget.title == 'New Applicants' &&
            selectedCategory == 'REGISTERED')
          PopupMenuItem<SampleItem>(
            value: SampleItem.verify,
            child: Row(
              children: [
                Icon(Icons.verified_outlined,
                    size: 18, color: cyanblueColor),
                const SizedBox(width: 10),
                const Text('Verify',
                    style: TextStyle(fontWeight: FontWeight.w500)),
              ],
            ),
          ),
      ],
    );
  }

  // ─── Organization List ───

  Widget _buildOrganizationList() {
    if (filteredUsers.isEmpty) {
      return _buildEmptyState(
        icon: Icons.business_outlined,
        message: 'No organization accounts found',
      );
    }

    return RefreshIndicator(
      color: cyanblueColor,
      onRefresh: () async {
        if (selectedCategory != null) await fetchUsers(selectedCategory!);
      },
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        itemCount: filteredUsers.length,
        itemBuilder: (context, index) {
          final org = filteredUsers[index];
          final List customers = org['customersInfo'] ?? [];
          final String companyName = org['companyName'] ?? 'Unknown Company';
          final String phone =
              org['companyPhoneNumber'] ?? org['phoneNumber'] ?? '';
          final String email = org['companyEmail'] ?? org['email'] ?? '';
          final String status = org['status'] ?? selectedCategory ?? '';
          final String initials = companyName.isNotEmpty
              ? companyName
                  .split(' ')
                  .map((w) => w.isNotEmpty ? w[0] : '')
                  .take(2)
                  .join()
                  .toUpperCase()
              : '?';

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              elevation: 1,
              shadowColor: Colors.black.withOpacity(0.08),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (modalContext) => OrganizationDetailPage(
                        org: org, parentContext: context),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              cyanblueColor,
                              cyanblueColor.withOpacity(0.7),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: Text(
                            initials,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              companyName,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1A1A2E),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                if (phone.isNotEmpty) ...[
                                  Icon(Icons.phone_outlined,
                                      size: 13, color: Colors.grey[500]),
                                  const SizedBox(width: 3),
                                  Text(phone,
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600])),
                                ],
                                if (phone.isNotEmpty && email.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6),
                                    child: Container(
                                      width: 3,
                                      height: 3,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[400],
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                if (email.isNotEmpty)
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Icon(Icons.email_outlined,
                                            size: 13, color: Colors.grey[500]),
                                        const SizedBox(width: 3),
                                        Expanded(
                                          child: Text(
                                            email,
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600]),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.people_outline,
                                    size: 13, color: Colors.grey[500]),
                                const SizedBox(width: 3),
                                Text(
                                  '${customers.length} ${customers.length == 1 ? 'signer' : 'signers'}',
                                  style: TextStyle(
                                      fontSize: 11, color: Colors.grey[500]),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (status.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: cyanblueColor.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                status[0] + status.substring(1).toLowerCase(),
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: cyanblueColor,
                                ),
                              ),
                            ),
                          const SizedBox(height: 6),
                          Icon(Icons.chevron_right,
                              color: Colors.grey[400], size: 20),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ─── Joint Account List ───

  Widget _buildJointAccountList() {
    if (filteredUsers.isEmpty) {
      return _buildEmptyState(
        icon: Icons.people_outline,
        message: 'No joint accounts found',
      );
    }

    return RefreshIndicator(
      color: cyanblueColor,
      onRefresh: () async {
        if (selectedCategory != null) await fetchUsers(selectedCategory!);
      },
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        itemCount: filteredUsers.length,
        itemBuilder: (context, index) {
          final jointAccount = filteredUsers[index];
          final String accountId = jointAccount['id']?.toString() ?? '';
          final String accountType = jointAccount['accountType'] ?? '';
          final String status = jointAccount['status'] ?? selectedCategory ?? '';
          final double initialDeposit =
              (jointAccount['initialDeposit'] ?? 0.0).toDouble();
          final List customers = jointAccount['customersInfo'] ?? [];

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              elevation: 1,
              shadowColor: Colors.black.withOpacity(0.08),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (modalContext) => JointAccountDetailPage(
                        jointAccount: jointAccount, parentContext: context),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              cyanblueColor,
                              cyanblueColor.withOpacity(0.7),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Center(
                          child: Icon(Icons.people, color: Colors.white, size: 22),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Joint Account #$accountId',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1A1A2E),
                              ),
                            ),
                            const SizedBox(height: 4),
                            if (accountType.isNotEmpty)
                              Text(
                                accountType,
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey[600]),
                              ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: cyanblueColor.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'ETB ${initialDeposit.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: cyanblueColor,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(Icons.people_outline,
                                    size: 13, color: Colors.grey[500]),
                                const SizedBox(width: 3),
                                Text(
                                  '${customers.length} holders',
                                  style: TextStyle(
                                      fontSize: 11, color: Colors.grey[500]),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (status.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: cyanblueColor.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                status[0] + status.substring(1).toLowerCase(),
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: cyanblueColor,
                                ),
                              ),
                            ),
                          const SizedBox(height: 6),
                          Icon(Icons.chevron_right,
                              color: Colors.grey[400], size: 20),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ─── Data Methods ───

  Future<void> fetchUsers(String status) async {
    setState(() {
      isLoading1 = true;
    });

    const storage = FlutterSecureStorage(
      aOptions: AndroidOptions(
        encryptedSharedPreferences: true,
        storageCipherAlgorithm: StorageCipherAlgorithm.AES_GCM_NoPadding,
      ),
    );
    String? token = await storage.read(key: "token");
    if (token != null && token.isNotEmpty) {
      var decodedToken = JwtDecoder.decode(token);
      setState(() {
        userId = decodedToken['userId'];
      });
    }

    String url =
        '/api/v1/accounts?customerType=$selectedCustomerType&status=$status&onlyUserCreated=true&size=100000';

    if (isOnline) {
      try {
        var response = await networkHandler.getUserData(url);
        if (response.statusCode == 200) {
          List<dynamic> fetchedUsers = jsonDecode(response.body);
          setState(() {
            users = fetchedUsers;
            filterUsers();
            isLoading1 = false;
          });
        } else {
          throw Exception('Failed to load users');
        }
      } catch (error) {
        print('Error fetching users: $error');
        setState(() {
          isLoading1 = false;
        });
      }
    } else {
      DatabaseHelper dbHelper = DatabaseHelper();
      List<Map<String, dynamic>> localUsers =
          await dbHelper.getCustomersByStatus(status, userId!);
      setState(() {
        users = localUsers;
        filterUsers();
        isLoading1 = false;
      });
    }
  }

  void filterUsers() {
    setState(() {
      filteredUsers = users
          .where((user) => (user['fullName']?.toLowerCase() ?? '')
              .contains(searchQuery.toLowerCase()))
          .toList();
    });
  }

  Future<void> _fetchToken() async {
    const storage = FlutterSecureStorage(
      aOptions: AndroidOptions(
        encryptedSharedPreferences: true,
        storageCipherAlgorithm: StorageCipherAlgorithm.AES_GCM_NoPadding,
      ),
    );
    String? token = await storage.read(key: "token");
    if (token != null && token.isNotEmpty) {
      var decodedToken = JwtDecoder.decode(token);
      setState(() {
        userId = decodedToken['userId'];
      });
    }
  }
}
