import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:family_organizer/models/thought.dart';
import 'package:family_organizer/services/thought_service.dart';
import 'package:family_organizer/services/auth_service.dart'; // To get the user token

class ThoughtsScreen extends StatefulWidget {
  const ThoughtsScreen({super.key});

  @override
  State<ThoughtsScreen> createState() => _ThoughtsScreenState();
}

class _ThoughtsScreenState extends State<ThoughtsScreen> {
  final TextEditingController _thoughtController = TextEditingController();
  final ThoughtService _thoughtService = ThoughtService();
  final List<Thought> _thoughts = [];
  int _currentPage = 1;
  bool _isLoading = false;
  bool _hasMore = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchThoughts();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent && _hasMore && !_isLoading) {
        _fetchThoughts();
      }
    });
  }

  @override
  void dispose() {
    _thoughtController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchThoughts() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final token = await authService.getToken();
      if (token == null) {
        // Handle unauthenticated state, e.g., navigate to login
        return;
      }

      final newThoughts = await _thoughtService.fetchThoughts(token, page: _currentPage);
      setState(() {
        _thoughts.addAll(newThoughts);
        _currentPage++;
        _hasMore = newThoughts.isNotEmpty;
      });
    } catch (e) {
      // Handle error
      print('Error fetching thoughts: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _postThought() async {
    if (_thoughtController.text.isEmpty) return;

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final token = await authService.getToken();
      if (token == null) {
        // Handle unauthenticated state
        return;
      }

      final newThought = await _thoughtService.postThought(_thoughtController.text, token);
      setState(() {
        _thoughts.insert(0, newThought); // Add new thought to the top
        _thoughtController.clear();
      });
    } catch (e) {
      // Handle error
      print('Error posting thought: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thoughts'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _thoughtController,
                    decoration: const InputDecoration(
                      hintText: 'Share a thought...',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: null,
                  ),
                ),
                const SizedBox(width: 8.0),
                ElevatedButton(
                  onPressed: _postThought,
                  child: const Text('Post'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _thoughts.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _thoughts.length) {
                  return const Center(child: CircularProgressIndicator());
                }
                final thought = _thoughts[index];
                return ThoughtBubble(thought: thought);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ThoughtBubble extends StatelessWidget {
  final Thought thought;

  const ThoughtBubble({super.key, required this.thought});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              thought.content,
              style: const TextStyle(fontSize: 16.0),
            ),
            const SizedBox(height: 8.0),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                '${thought.user.username} - ${thought.timestamp.toLocal().toString().split('.')[0]}',
                style: const TextStyle(fontSize: 12.0, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
