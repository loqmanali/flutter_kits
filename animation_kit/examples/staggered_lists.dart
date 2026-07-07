import 'package:flutter/material.dart';

import 'package:animation_kit/animation_kit.dart';

/// Staggered Lists Example
///
/// Demonstrates staggered animations for lists and grids.
///
/// This example shows:
/// - Staggered fade-in for lists
/// - Staggered list view
/// - Staggered grid view
/// - Different stagger directions (forward, reverse, fromCenter)
class StaggeredListsExample extends StatefulWidget {
  const StaggeredListsExample({super.key});

  @override
  State<StaggeredListsExample> createState() => _StaggeredListsExampleState();
}

class _StaggeredListsExampleState extends State<StaggeredListsExample> {
  final List<String> _items = List.generate(
    20,
    (index) => 'Item ${index + 1}',
  );

  StaggerDirection _selectedDirection = StaggerDirection.forward;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Staggered Lists'),
      ),
      body: Column(
        children: [
          _buildDirectionSelector(),
          Expanded(
            child: DefaultTabController(
              length: 3,
              child: Column(
                children: [
                  const TabBar(
                    tabs: [
                      Tab(text: 'List'),
                      Tab(text: 'Grid'),
                      Tab(text: 'Fade In'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildListView(),
                        _buildGridView(),
                        _buildFadeInExample(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDirectionSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[100],
      child: Row(
        children: [
          const Text('Stagger Direction: '),
          const SizedBox(width: 16),
          DropdownButton<StaggerDirection>(
            value: _selectedDirection,
            items: const [
              DropdownMenuItem(
                value: StaggerDirection.forward,
                child: Text('Forward'),
              ),
              DropdownMenuItem(
                value: StaggerDirection.reverse,
                child: Text('Reverse'),
              ),
              DropdownMenuItem(
                value: StaggerDirection.fromCenter,
                child: Text('From Center'),
              ),
            ],
            onChanged: (value) {
              setState(() {
                _selectedDirection = value ?? StaggerDirection.forward;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildListView() {
    return StaggeredListView(
      staggerConfig: StaggerConfig(
        direction: _selectedDirection,
      ),
      itemCount: _items.length,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: CircleAvatar(
              child: Text('${index + 1}'),
            ),
            title: Text(_items[index]),
            subtitle: Text('Item description ${index + 1}'),
            trailing: const Icon(Icons.arrow_forward_ios),
          ),
        );
      },
    );
  }

  Widget _buildGridView() {
    return StaggeredGridView(
      staggerConfig: StaggerConfig(
        direction: _selectedDirection,
        delay: const Duration(milliseconds: 30),
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _items.length,
      itemBuilder: (context, index) {
        final colors = [
          Colors.blue,
          Colors.green,
          Colors.orange,
          Colors.purple,
          Colors.pink,
          Colors.teal,
        ];
        final color = colors[index % colors.length];

        return Card(
          color: color,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.star,
                size: 48,
                color: Colors.white,
              ),
              const SizedBox(height: 8),
              Text(
                _items[index],
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFadeInExample() {
    return StaggeredFadeIn(
      staggerConfig: StaggerConfig(
        direction: _selectedDirection,
        delay: const Duration(milliseconds: 40),
      ),
      itemCount: _items.length,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.indigo[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.indigo,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _items[index],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'This is item ${index + 1} description',
                      style: TextStyle(
                        color: Colors.grey[600],
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
}
