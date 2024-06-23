import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(HighLowCardGameApp());
}

class HighLowCardGameApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'High and Low Card Game',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        textTheme: TextTheme(
          bodyText2: TextStyle(fontFamily: 'GameFont'),
        ),
      ),
      home: MainMenuPage(),
    );
  }
}

class MainMenuPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Main Menu', style: TextStyle(fontFamily: 'GameFont')),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          image: DecorationImage(
            image: AssetImage('assets/wbg.jpg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.5),
              BlendMode.dstATop,
            ),
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/hilo.png', height: 180),
              SizedBox(height: 40),
              _buildCoolButton(context, 'Tap the Game', Color(0xff585858), () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GamePage(),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCoolButton(
      BuildContext context, String text, Color color, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 200,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.8), color],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              fontFamily: 'GameFont',
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class GamePage extends StatefulWidget {
  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage>
    with SingleTickerProviderStateMixin {
  final List<String> suits = ['♠', '♥', '♦', '♣'];
  int currentCardValue = 0;
  String currentCardSuit = '';
  String message = '';
  int score = 0;
  late AnimationController _controller;
  late Animation<double> _flipAnimation;
  bool isFront = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 700),
      vsync: this,
    );
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    _drawCard();
  }

  void _drawCard() {
    setState(() {
      currentCardValue = Random().nextInt(13) + 1;
      currentCardSuit = suits[Random().nextInt(4)];
    });
  }

  void _guess(bool isHigher) {
    int oldCardValue = currentCardValue;
    _controller.forward().then((_) {
      setState(() {
        isFront = !isFront;
        _drawCard();
        if ((isHigher && currentCardValue > oldCardValue) ||
            (!isHigher && currentCardValue < oldCardValue)) {
          message = 'Correct!';
          score++;
        } else {
          message = 'Wrong!';
          score = max(0, score - 1);
        }
      });
      _controller.reverse();
    });
  }

  Widget _buildCard() {
    return AnimatedBuilder(
      animation: _flipAnimation,
      builder: (context, child) {
        final angle = _flipAnimation.value * pi;
        final transform = Matrix4.identity()
          ..rotateY(angle)
          ..rotateZ(angle / 6)
          ..scale(1.1 - _flipAnimation.value * 0.2);

        return Transform(
          transform: transform,
          alignment: Alignment.center,
          child: _buildCardFace(),
        );
      },
    );
  }

  Widget _buildCardFace() {
    return GestureDetector(
      onTap: () {
        if (!isFront) {
          _controller.reverse();
          setState(() {
            isFront = !isFront;
          });
        }
      },
      child: Container(
        width: 150,
        height: 250,
        decoration: BoxDecoration(
          color: Color(0xff242323), // Change card color here
          borderRadius: BorderRadius.circular(20.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
            BoxShadow(
              color: Colors.white.withOpacity(0.2),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              top: 16,
              left: 16,
              child: Text(
                currentCardValue.toString(),
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Color(0xffc3c3c3),
                  fontFamily: 'GameFont',
                  shadows: [
                    Shadow(
                      offset: Offset(2, 2),
                      blurRadius: 4,
                      color: Colors.black,
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 16,
              right: 16,
              child: Text(
                currentCardSuit,
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: 'GameFont',
                  shadows: [
                    Shadow(
                      offset: Offset(2, 2),
                      blurRadius: 4,
                      color: Colors.black,
                    ),
                  ],
                ),
              ),
            ),
            if (!isFront)
              Center(
                child: Text(
                  message,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'GameFont',
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuessButton(String label, bool isHigher) {
    return GestureDetector(
      onTap: () => _guess(isHigher),
      child: Container(
        width: 120,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.grey.shade600, Colors.grey.shade400],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'GameFont',
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var textStyle = TextStyle(
      fontSize: 18,
      fontFamily: 'GameFont',
    );
    return Scaffold(
      appBar: AppBar(
        title: Text('High and Low Card Game',
            style: TextStyle(fontFamily: 'GameFont')),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: _exitGame,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/casinocard.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Welcome!',
                style: textStyle,
              ),
              SizedBox(height: 20),
              _buildCard(),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildGuessButton('Higher', true),
                  _buildGuessButton('Lower', false),
                ],
              ),
              SizedBox(height: 20),
              Text(
                'Score: $score',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'GameFont'),
              ),
              SizedBox(height: 20),
              _buildCoolButton(
                  context, 'Exit Game', Color(0xff686767), _exitGame),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCoolButton(
      BuildContext context, String text, Color color, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 200,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.8), color],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              fontFamily: 'GameFont',
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  void _exitGame() {
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
