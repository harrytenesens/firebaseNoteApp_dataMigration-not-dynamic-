
import 'package:flutter/material.dart';

class UserHeader extends StatefulWidget {
  const UserHeader({super.key, required this.userdata, required this.onPressed});
    
    final Map userdata;
    final void Function()? onPressed;

  @override
  State<UserHeader> createState() => _UserHeaderState();
}

class _UserHeaderState extends State<UserHeader> {
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.userdata['first Name'] ?? 'Loading..',
                      style:
                          const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(widget.userdata['last name'] ?? 'loadinig..'),
                  ],
                ),
                ElevatedButton(
                  onPressed: widget.onPressed,
                  
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13)),
                    minimumSize: const Size(40, 40),
                    backgroundColor: const Color.fromARGB(255, 8, 49, 110),
                  ),
                  child: const Text(
                    "Sign Out",
                    style: TextStyle(color: Colors.white),
                  ),
                  
                )
              ],
            ),
          ],
        ),
      );
  }
}