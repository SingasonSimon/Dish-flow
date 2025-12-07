import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../widgets/recipe_card.dart';
import '../../../widgets/rounded_pill_button.dart';
import '../../../providers/auth_providers.dart';
import '../../../providers/user_providers.dart';
import '../../../providers/recipe_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(currentUserIdProvider);
    final userProfileAsync = ref.watch(currentUserProfileProvider);
    final userRecipesAsync = userId != null
        ? ref.watch(userRecipesProvider(userId))
        : null;
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: userProfileAsync.when(
          data: (userProfile) => SingleChildScrollView(
            child: Column(
              children: [
                // Profile Header
                Container(
                  padding: const EdgeInsets.all(AppConstants.spacingL),
                  child: Column(
                    children: [
                      // Avatar
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: AppTheme.primaryColor,
                            backgroundImage: userProfile?.photoURL != null
                                ? NetworkImage(userProfile!.photoURL!)
                                : null,
                            child: userProfile?.photoURL == null
                                ? const Icon(
                                    Icons.person,
                                    size: 50,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: AppTheme.primaryColor,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppConstants.spacingM),
                      // Username
                      Text(
                        userProfile?.displayName ?? 'User',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: AppConstants.spacingXS),
                      Text(
                        userProfile?.email ?? '',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                      ),
                      const SizedBox(height: AppConstants.spacingL),
                      // Stats
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatColumn(
                            context,
                            'Recipes',
                            '${userProfile?.recipesCount ?? 0}',
                          ),
                          _buildStatColumn(
                            context,
                            'Likes',
                            '${userProfile?.likesCount ?? 0}',
                          ),
                          _buildStatColumn(
                            context,
                            'Saved',
                            '${userProfile?.savedCount ?? 0}',
                          ),
                        ],
                      ),
                      const SizedBox(height: AppConstants.spacingL),
                      // Edit Profile Button
                      OutlinedButton.icon(
                        onPressed: () {
                          // TODO: Navigate to edit profile
                        },
                        icon: const Icon(Icons.edit_outlined),
                        label: const Text('Edit Profile'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppConstants.spacingXL,
                            vertical: AppConstants.spacingM,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppConstants.radiusPill,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // My Recipes Section
                if (userId != null && userRecipesAsync != null)
                  Padding(
                    padding: const EdgeInsets.all(AppConstants.spacingL),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'My Recipes',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: AppConstants.spacingM),
                        userRecipesAsync.when(
                          data: (recipes) => recipes.isEmpty
                              ? Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(
                                      AppConstants.spacingXL,
                                    ),
                                    child: Text(
                                      'No recipes yet',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: AppTheme.textSecondary,
                                          ),
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: recipes.length,
                                  itemBuilder: (context, index) {
                                    final recipe = recipes[index];
                                    return RecipeCard(
                                      id: recipe.id,
                                      title: recipe.title,
                                      imageUrl: recipe.imageUrl,
                                      authorName: recipe.authorName,
                                      likesCount: recipe.likesCount,
                                      rating: recipe.rating,
                                      onTap: () =>
                                          context.push('/recipe/${recipe.id}'),
                                    );
                                  },
                                ),
                          loading: () => const Center(
                            child: CircularProgressIndicator(),
                          ),
                          error: (error, stack) => Text(
                            'Error loading recipes',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                // Logout Button
                Padding(
                  padding: const EdgeInsets.all(AppConstants.spacingL),
                  child: RoundedPillButton(
                    text: 'Logout',
                    onPressed: () async {
                      final authService = ref.read(authServiceProvider);
                      await authService.signOut();
                      if (context.mounted) {
                        context.go('/login');
                      }
                    },
                    backgroundColor: AppTheme.errorColor,
                  ),
                ),
                const SizedBox(height: AppConstants.spacingXL),
              ],
            ),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Text('Error: $error'),
          ),
        ),
      ),
    );
  }

  Widget _buildStatColumn(BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppTheme.primaryColor,
              ),
        ),
        const SizedBox(height: AppConstants.spacingXS),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondary,
              ),
        ),
      ],
    );
  }
}

