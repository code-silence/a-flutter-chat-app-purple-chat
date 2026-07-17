import 'package:flutter/material.dart';
import '../../../auth/models/user_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/friend_provider.dart';
import '../../../chat/presentation/screens/chat_screen.dart';

class ProfileActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const ProfileActionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        leading: Icon(icon, color: color),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
      ),
    );
  }
}

class FriendProfileScreen extends ConsumerWidget {
  final UserModel friend;

  const FriendProfileScreen({super.key, required this.friend});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 210,
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).colorScheme.primary,
                            Theme.of(context).colorScheme.primaryContainer,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(40),
                          bottomRight: Radius.circular(40),
                        ),
                      ),
                    ),

                    Positioned(
                      top: -40,
                      right: -20,
                      child: Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.08),
                        ),
                      ),
                    ),

                    Positioned(
                      bottom: -35,
                      left: -25,
                      child: Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.06),
                        ),
                      ),
                    ),

                    Positioned(
                      top: 55,
                      left: 35,
                      child: Icon(
                        Icons.auto_awesome_rounded,
                        color: Colors.white.withValues(alpha: 0.18),
                        size: 36,
                      ),
                    ),

                    Positioned(
                      top: 30,
                      right: 70,
                      child: Icon(
                        Icons.bubble_chart_rounded,
                        color: Colors.white.withValues(alpha: 0.15),
                        size: 28,
                      ),
                    ),
                  ],
                ),
              ),

              Transform.translate(
                offset: const Offset(0, -70),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.35),
                        blurRadius: 25,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 58,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 54,
                      backgroundImage: friend.photoUrl.isNotEmpty
                          ? NetworkImage(friend.photoUrl)
                          : null,
                      child: friend.photoUrl.isEmpty
                          ? const Icon(Icons.person, size: 55)
                          : null,
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  friend.displayName,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 6),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  '@${friend.username}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        friend.isOnline
                            ? Icons.circle
                            : Icons.access_time_filled_rounded,
                        size: 16,
                        color: friend.isOnline ? Colors.green : Colors.orange,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        friend.isOnline ? "Online" : "Offline",
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),

              Card(
                elevation: 0,
                margin: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.info_outline_rounded),
                          SizedBox(width: 8),
                          Text(
                            "Bio",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Text(
                        friend.bio.isEmpty
                            ? "\"User is too lazy to add a bio :3\""
                            : friend.bio,
                        style: TextStyle(
                          color: friend.bio.isEmpty
                              ? Theme.of(context).colorScheme.onSurfaceVariant
                                    .withValues(alpha: 0.6)
                              : null,
                          fontStyle: friend.bio.isEmpty
                              ? FontStyle.italic
                              : FontStyle.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Card(
                elevation: 0,
                margin: const EdgeInsets.symmetric(horizontal: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                child: ListTile(
                  leading: const Icon(Icons.alternate_email_rounded),
                  title: const Text("Username"),
                  subtitle: Text("@${friend.username}"),
                ),
              ),

              const SizedBox(height: 24),
              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    icon: const Icon(Icons.chat_bubble_rounded),
                    label: const Text("Message"),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatScreen(friend: friend),
                        ),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 12),

              ProfileActionCard(
                icon: Icons.person_remove_rounded,
                title: "Remove Friend",
                color: Colors.orange,
                onTap: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Remove Friend'),
                        content: Text(
                          'Remove ${friend.displayName} from your friends?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Remove'),
                          ),
                        ],
                      );
                    },
                  );

                  if (confirm != true) return;

                  await ref
                      .read(friendRepositoryProvider)
                      .removeFriend(friend.uid);

                  if (!context.mounted) return;

                  Navigator.pop(context);
                },
              ),

              const SizedBox(height: 12),

              ProfileActionCard(
                icon: Icons.block_rounded,
                title: "Block User",
                color: Colors.red,
                onTap: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Block User'),
                      content: Text(
                        'Block ${friend.displayName}? They will no longer be able to message or send friend requests.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Block'),
                        ),
                      ],
                    ),
                  );

                  if (confirm != true) return;

                  await ref
                      .read(friendRepositoryProvider)
                      .blockUser(friend.uid);

                  if (!context.mounted) return;

                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
