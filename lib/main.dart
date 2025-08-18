import 'package:flutter/material.dart';

void main() {

  runApp(SecureChatApp());

}

class SecureChatApp extends StatefulWidget {

  @override

  State<SecureChatApp> createState() => _SecureChatAppState();

}

class _SecureChatAppState extends State<SecureChatApp> {

  bool darkMode = true; // inicializa como escuro

  @override

  Widget build(BuildContext context) {

    return MaterialApp(

      title: 'SecureChat',

      theme: ThemeData(

        colorSchemeSeed: Color(0xFF4A148C), // roxo escuro

        useMaterial3: true,

        brightness: Brightness.light,

      ),

      darkTheme: ThemeData(

        colorSchemeSeed: Color(0xFF4A148C),

        useMaterial3: true,

        brightness: Brightness.dark,

      ),

      themeMode: darkMode ? ThemeMode.dark : ThemeMode.light,

      home: HomeScreen(

        darkMode: darkMode,

        onToggleTheme: () => setState(() => darkMode = !darkMode),

      ),

    );

  }

}

class HomeScreen extends StatefulWidget {

  final bool darkMode;

  final VoidCallback onToggleTheme;

  HomeScreen({required this.darkMode, required this.onToggleTheme});

  @override

  State<HomeScreen> createState() => _HomeScreenState();

}

enum TabItem { chats, contacts, settings }

class _HomeScreenState extends State<HomeScreen> {

  TabItem currentTab = TabItem.chats;

  final contacts = [

    {'name': 'João', 'email': 'joao@example.com'},

    {'name': 'Ana', 'email': 'ana@example.com'},

  ];

  Map<String, List<Map<String, dynamic>>> conversations = {

    'joao@example.com': [{'text': 'Mensagem criptografada...', 'sent': false}],

    'ana@example.com': [{'text': 'Oi! 👋', 'sent': true}],

  };

  bool privateKeySaved = false;

  String? currentChatEmail;

  void openChat(String email) {

    setState(() {

      currentChatEmail = email;

    });

  }

  void closeChat() {

    setState(() {

      currentChatEmail = null;

    });

  }

  void sendMessage(String email, String text) {

    setState(() {

      conversations[email] = [

        ...?conversations[email],

        {'text': text, 'sent': true}

      ];

    });

    Future.delayed(Duration(seconds: 2), () {

      setState(() {

        conversations[email] = [

          ...?conversations[email],

          {'text': 'Resposta: $text', 'sent': false}

        ];

      });

    });

  }

  @override

  Widget build(BuildContext context) {

    if (currentChatEmail != null) {

      final contact = contacts.firstWhere((c) => c['email'] == currentChatEmail);

      final messages = conversations[currentChatEmail] ?? [];

      return Scaffold(

        appBar: AppBar(

          title: Text(contact['name']!),

          leading: IconButton(

            icon: Icon(Icons.arrow_back),

            onPressed: closeChat,

          ),

        ),

        body: ChatScreen(

          messages: messages,

          onSend: (text) => sendMessage(currentChatEmail!, text),

        ),

      );

    }

    return Scaffold(

      appBar: AppBar(

        title: Text('🔐 SecureChat'),

      ),

      body: IndexedStack(

        index: currentTab.index,

        children: [

          ChatsTab(

            contacts: contacts,

            conversations: conversations,

            onOpenChat: openChat,

          ),

          ContactsTab(contacts: contacts),

          SettingsTab(

            privateKeySaved: privateKeySaved,

            onSave: () => setState(() => privateKeySaved = true),

            onReset: () => setState(() => privateKeySaved = false),

            darkMode: widget.darkMode,

            onToggleTheme: widget.onToggleTheme,

          ),

        ],

      ),

      bottomNavigationBar: NavigationBar(

        selectedIndex: currentTab.index,

        onDestinationSelected: (i) {

          setState(() {

            currentTab = TabItem.values[i];

          });

        },

        destinations: [

          NavigationDestination(icon: Icon(Icons.chat), label: 'Conversas'),

          NavigationDestination(icon: Icon(Icons.people), label: 'Contatos'),

          NavigationDestination(icon: Icon(Icons.settings), label: 'Configurações'),

        ],

      ),

      floatingActionButton: currentTab == TabItem.chats

          ? FloatingActionButton(

              onPressed: () {

                // Abrir modal para novo contato/conversa

              },

              child: Icon(Icons.add),

            )

          : null,

    );

  }

}

class ChatsTab extends StatelessWidget {

  final List<Map<String, String>> contacts;

  final Map<String, List<Map<String, dynamic>>> conversations;

  final Function(String) onOpenChat;

  ChatsTab({required this.contacts, required this.conversations, required this.onOpenChat});

  @override

  Widget build(BuildContext context) {

    return ListView(

      children: contacts.map((c) {

        final msgs = conversations[c['email']] ?? [];

        final lastMsg = msgs.isNotEmpty ? msgs.last['text'] : 'Sem mensagens ainda';

        return ListTile(

          leading: CircleAvatar(child: Text(c['name']![0])),

          title: Text(c['name']!),

          subtitle: Text(lastMsg),

          onTap: () => onOpenChat(c['email']!),

        );

      }).toList(),

    );

  }

}

class ContactsTab extends StatelessWidget {

  final List<Map<String, String>> contacts;

  ContactsTab({required this.contacts});

  @override

  Widget build(BuildContext context) {

    return ListView(

      children: contacts.map((c) {

        return ListTile(

          leading: CircleAvatar(child: Text(c['name']![0])),

          title: Text(c['name']!),

          subtitle: Text(c['email']!),

        );

      }).toList(),

    );

  }

}

class SettingsTab extends StatelessWidget {

  final bool privateKeySaved;

  final VoidCallback onSave;

  final VoidCallback onReset;

  final bool darkMode;

  final VoidCallback onToggleTheme;

  SettingsTab({

    required this.privateKeySaved,

    required this.onSave,

    required this.onReset,

    required this.darkMode,

    required this.onToggleTheme,

  });

  @override

  Widget build(BuildContext context) {

    return Padding(

      padding: EdgeInsets.all(16),

      child: Column(

        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          Text('Chave privada', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

          SizedBox(height: 12),

          privateKeySaved

              ? Column(

                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [

                    Row(

                      children: [

                        Icon(Icons.lock, color: Colors.green),

                        SizedBox(width: 8),

                        Text('Chave ativada 🔒'),

                      ],

                    ),

                    SizedBox(height: 8),

                    ElevatedButton(onPressed: onReset, child: Text('Trocar chave')),

                  ],

                )

              : Column(

                  children: [

                    TextField(

                      maxLines: 4,

                      decoration: InputDecoration(

                        border: OutlineInputBorder(),

                        hintText: 'Cole sua chave privada aqui',

                      ),

                    ),

                    SizedBox(height: 8),

                    ElevatedButton(

                      onPressed: () {

                        onSave();

                        ScaffoldMessenger.of(context).showSnackBar(

                          SnackBar(content: Text('⚠️ Sua chave ficará oculta por segurança')),

                        );

                      },

                      child: Text('Salvar chave'),

                    ),

                  ],

                ),

          Divider(height: 32),

          Text('Tema', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

          SizedBox(height: 8),

          Row(

            children: [

              Text(darkMode ? 'Escuro 🌙' : 'Claro ☀️'),

              Switch(value: darkMode, onChanged: (_) => onToggleTheme()),

            ],

          ),

        ],

      ),

    );

  }

}

class ChatScreen extends StatefulWidget {

  final List<Map<String, dynamic>> messages;

  final Function(String) onSend;

  ChatScreen({required this.messages, required this.onSend});

  @override

  State<ChatScreen> createState() => _ChatScreenState();

}

class _ChatScreenState extends State<ChatScreen> {

  final controller = TextEditingController();

  bool showEmoji = false;

  final emojis = ['😀', '😂', '😍', '😎', '🤔', '😢', '👍', '🙏'];

  void insertEmoji(String emoji) {

    controller.text += emoji;

    controller.selection = TextSelection.fromPosition(

      TextPosition(offset: controller.text.length),

    );

  }

  @override

  Widget build(BuildContext context) {

    return Column(

      children: [

        Expanded(

          child: ListView(

            padding: EdgeInsets.all(12),

            children: widget.messages.map((m) {

              final sent = m['sent'] as bool;

              return Row(

                mainAxisAlignment: sent ? MainAxisAlignment.end : MainAxisAlignment.start,

                children: [

                  Container(

                    margin: EdgeInsets.symmetric(vertical: 4),

                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),

                    decoration: BoxDecoration(

                      color: sent

                          ? Colors.deepPurple[200]

                          : Theme.of(context).colorScheme.surfaceVariant,

                      borderRadius: BorderRadius.circular(12),

                    ),

                    child: Text(

                      m['text'],

                      style: TextStyle(

                        color: sent

                            ? Colors.black

                            : Theme.of(context).colorScheme.onSurfaceVariant,

                      ),

                    ),

                  ),

                ],

              );

            }).toList(),

          ),

        ),

        if (showEmoji)

          Container(

            height: 200,

            child: GridView.count(

              crossAxisCount: 8,

              children: emojis.map((e) {

                return InkWell(

                  onTap: () => insertEmoji(e),

                  child: Center(child: Text(e, style: TextStyle(fontSize: 24))),

                );

              }).toList(),

            ),

          ),

        Row(

          children: [

            IconButton(

              icon: Icon(Icons.emoji_emotions),

              onPressed: () => setState(() => showEmoji = !showEmoji),

            ),

            Expanded(

              child: TextField(

                controller: controller,

                decoration: InputDecoration(hintText: 'Digite sua mensagem…'),

              ),

            ),

            IconButton(

              icon: Icon(Icons.send, color: Colors.deepPurple),

              onPressed: () {

                if (controller.text.trim().isEmpty) return;

                widget.onSend(controller.text.trim());

                controller.clear();

              },

            ),

          ],

        ),

      ],

    );

  }

}