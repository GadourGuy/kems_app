import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/constants.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/loading_widget.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});
  
  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;
  
  final List<Widget> _tabs = [
    const UsersManagementTab(),
    const RolesManagementTab(),
    const SystemStatsTab(),
  ];
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: AppColors.surface,
            child: TabBar(
              tabs: const [
                Tab(text: 'Users', icon: Icon(Icons.people)),
                Tab(text: 'Roles', icon: Icon(Icons.admin_panel_settings)),
                Tab(text: 'Stats', icon: Icon(Icons.analytics)),
              ],
              onTap: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.primary,
            ),
          ),
        ),
      ),
      body: _tabs[_selectedIndex],
    );
  }
}

class UsersManagementTab extends StatelessWidget {
  const UsersManagementTab({super.key});
  
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection(AppConstants.collectionUsers)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingWidget(message: 'Loading users...');
        }
        
        final users = snapshot.data!.docs;
        
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            final userData = user.data() as Map<String, dynamic>;
            
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: Text(
                    userData['name'][0].toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  userData['name'],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(userData['email']),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _getRoleColor(userData['role']).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        userData['role'].toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          color: _getRoleColor(userData['role']),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                trailing: PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) {
                    if (value == 'change_role') {
                      _showChangeRoleDialog(context, user.id, userData['role']);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'change_role',
                      child: Row(
                        children: [
                          Icon(Icons.admin_panel_settings, size: 18),
                          SizedBox(width: 8),
                          Text('Change Role'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
  
  Color _getRoleColor(String role) {
    switch (role) {
      case AppConstants.roleAdmin:
        return Colors.red;
      case AppConstants.roleOrganizer:
        return Colors.orange;
      case AppConstants.roleVolunteer:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
  
  void _showChangeRoleDialog(BuildContext context, String userId, String currentRole) {
    String selectedRole = currentRole;
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Change User Role'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Select new role for this user:'),
              const SizedBox(height: 16),
              DropdownButton<String>(
                value: selectedRole,
                isExpanded: true,
                items: const [
                  DropdownMenuItem(
                    value: AppConstants.roleAdmin,
                    child: Text('Administrator'),
                  ),
                  DropdownMenuItem(
                    value: AppConstants.roleOrganizer,
                    child: Text('Event Organizer'),
                  ),
                  DropdownMenuItem(
                    value: AppConstants.roleVolunteer,
                    child: Text('Volunteer'),
                  ),
                ],
                onChanged: (value) {
                  selectedRole = value!;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection(AppConstants.collectionUsers)
                    .doc(userId)
                    .update({'role': selectedRole});
                
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('User role updated successfully'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }
}

class RolesManagementTab extends StatelessWidget {
  const RolesManagementTab({super.key});
  
  @override
  Widget build(BuildContext context) {
    final roles = [
      {
        'name': 'Administrator',
        'role': AppConstants.roleAdmin,
        'description': 'Full system access with all permissions',
        'color': Colors.red,
        'permissions': [
          'Manage all users',
          'Change user roles',
          'Access admin dashboard',
          'Manage all events',
          'Approve/reject proposals',
          'View analytics',
        ],
      },
      {
        'name': 'Event Organizer',
        'role': AppConstants.roleOrganizer,
        'description': 'Can create and manage events',
        'color': Colors.orange,
        'permissions': [
          'Create events',
          'Manage own events',
          'View volunteer signups',
          'Generate reports',
          'Upload event proposals',
        ],
      },
      {
        'name': 'Volunteer',
        'role': AppConstants.roleVolunteer,
        'description': 'Basic user with limited access',
        'color': Colors.green,
        'permissions': [
          'View events',
          'Sign up for events',
          'Manage own profile',
          'Submit event feedback',
          'View certificates',
        ],
      },
    ];
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: roles.length,
      itemBuilder: (context, index) {
        final role = roles[index];
        
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: ExpansionTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (role['color'] as Color).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getRoleIcon(role['role'] as String),
                color: role['color'] as Color,
              ),
            ),
            title: Text(
              role['name'] as String,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(role['description'] as String),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Permissions:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...(role['permissions'] as List<String>).map(
                      (permission) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              size: 16,
                              color: role['color'] as Color,
                            ),
                            const SizedBox(width: 8),
                            Text(permission),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  IconData _getRoleIcon(String role) {
    switch (role) {
      case AppConstants.roleAdmin:
        return Icons.admin_panel_settings;
      case AppConstants.roleOrganizer:
        return Icons.event;
      case AppConstants.roleVolunteer:
        return Icons.volunteer_activism;
      default:
        return Icons.person;
    }
  }
}

class SystemStatsTab extends StatelessWidget {
  const SystemStatsTab({super.key});
  
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.wait([
        FirebaseFirestore.instance.collection(AppConstants.collectionUsers).get(),
        FirebaseFirestore.instance.collection(AppConstants.collectionEvents).get(),
        FirebaseFirestore.instance.collection(AppConstants.collectionProposals).get(),
      ]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingWidget(message: 'Loading statistics...');
        }
        
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        
        final users = snapshot.data![0];
        final events = snapshot.data![1];
        final proposals = snapshot.data![2];
        
        final adminCount = users.docs.where((doc) => doc['role'] == AppConstants.roleAdmin).length;
        final organizerCount = users.docs.where((doc) => doc['role'] == AppConstants.roleOrganizer).length;
        final volunteerCount = users.docs.where((doc) => doc['role'] == AppConstants.roleVolunteer).length;
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Stats Cards
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  _buildStatCard(
                    'Total Users',
                    users.docs.length.toString(),
                    Icons.people,
                    Colors.blue,
                  ),
                  _buildStatCard(
                    'Total Events',
                    events.docs.length.toString(),
                    Icons.event,
                    Colors.green,
                  ),
                  _buildStatCard(
                    'Proposals',
                    proposals.docs.length.toString(),
                    Icons.description,
                    Colors.orange,
                  ),
                  _buildStatCard(
                    'Active Users',
                    users.docs.where((doc) => doc['isActive'] == true).length.toString(),
                    Icons.verified_user,
                    Colors.purple,
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Role Distribution
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'User Role Distribution',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildRoleDistributionItem(
                        'Administrators',
                        adminCount,
                        users.docs.length,
                        Colors.red,
                      ),
                      const SizedBox(height: 12),
                      _buildRoleDistributionItem(
                        'Organizers',
                        organizerCount,
                        users.docs.length,
                        Colors.orange,
                      ),
                      const SizedBox(height: 12),
                      _buildRoleDistributionItem(
                        'Volunteers',
                        volunteerCount,
                        users.docs.length,
                        Colors.green,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildRoleDistributionItem(String role, int count, int total, Color color) {
    final percentage = total > 0 ? (count / total) * 100 : 0;
    
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(role),
            ),
            Text(
              '$count users (${percentage.toStringAsFixed(1)}%)',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: percentage / 100,
          backgroundColor: color.withOpacity(0.1),
          color: color,
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }
}