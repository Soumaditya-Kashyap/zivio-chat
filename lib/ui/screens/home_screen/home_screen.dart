import 'dart:developer';
import 'package:chat_app/core/constants/colors.dart';
import 'package:chat_app/core/constants/strings.dart';
import 'package:chat_app/core/constants/styles.dart';
import 'package:chat_app/core/models/user_models.dart';
import 'package:chat_app/core/services/database_service.dart';
import 'package:chat_app/ui/others/user_provider.dart';
import 'package:chat_app/ui/screens/home_screen/home_viewmodel.dart';
import 'package:chat_app/ui/widgets/textfiled_widgte.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chat_app/ui/screens/bottom_navigation/bottom_navigation_viewmodel.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final currentUser = userProvider.user;

    return ChangeNotifierProvider(
      create: (context) {
        final viewModel = HomeViewmodel(DatabaseService());
        if (currentUser?.uid != null) {
          viewModel.setCurrentUserId(currentUser!.uid!);
        }
        return viewModel;
      },
      
      child: Consumer<HomeViewmodel>(builder: (context, model, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Find People', style: heading),
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                final navViewModel = Provider.of<BottomNavigationViewmodel>(
                  context,
                  listen: false,
                );
                navViewModel.setIndex(1);
              },
            ),
          ),
          
          body: Column(
            children: [
              // Search bar
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                child: CustomTextfield(
                  controller: model.searchController,
                  hintText: 'Search users...',
                  onChanged: model.setSearchQuery,
                  isSearch: true,
                ),
              ),

              // Results
              Expanded(
                child: model.isSearching
                    ? const Center(child: CircularProgressIndicator())
                    : model.searchQuery.isEmpty
                        ? _buildSuggestionsSection()
                        : _buildSearchResults(model, context),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSuggestionsSection() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search, size: 80, color: grey.withAlpha(100)),
          SizedBox(height: 16),
          Text(
            'Search for users to start a conversation',
            textAlign: TextAlign.center,
            style: body.copyWith(color: grey),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(HomeViewmodel model, BuildContext context) {
    if (model.searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_search, size: 80, color: grey.withAlpha(100)),
            SizedBox(height: 16),
            Text(
              'No users found',
              textAlign: TextAlign.center,
              style: body.copyWith(color: grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: model.searchResults.length,
      itemBuilder: (context, index) {
        final user = model.searchResults[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: grey.withAlpha(75),
            child: user.imageUrl != null && user.imageUrl!.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: Image.network(
                      user.imageUrl!,
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Text(
                        user.name?[0] ?? '?',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  )
                : Text(
                    user.name?[0] ?? '?',
                    style: TextStyle(color: Colors.white),
                  ),
          ),
          title: Text(user.name ?? 'User'),
          subtitle: Text(user.email ?? ''),
          trailing: IconButton(
            icon: Icon(Icons.chat, color: primary),
            onPressed: () {
              Navigator.pushNamed(
                context,
                chatRoom,
                arguments: user,
              );
            },
          ),
          onTap: () {
            Navigator.pushNamed(
              context,
              chatRoom,
              arguments: user,
            );
          },
        );
      },
    );
  }

  // Utility function to migrate existing users to have nameSearch field
  Future<void> _migrateUsersToHaveNameSearch(BuildContext context) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final usersSnapshot = await firestore.collection('users').get();

      int migratedCount = 0;

      for (var doc in usersSnapshot.docs) {
        final userData = doc.data();
        if (userData['nameSearch'] == null && userData['name'] != null) {
          final name = userData['name'] as String;
          final nameSearch = UserModels.generateSearchKeywords(name);

          await firestore.collection('users').doc(doc.id).update({
            'nameSearch': nameSearch,
          });

          migratedCount++;
          log('Migrated user: ${userData['name']} (${doc.id})');
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Migrated $migratedCount users to have nameSearch field')),
      );
    } catch (e) {
      log('Error migrating users: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error migrating users: $e')),
      );
    }
  }
}
