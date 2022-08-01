import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:mpickflutter/Helpers/super_mc_share.dart';
import 'package:mpickflutter/Helpers/world.dart';
import 'package:mpickflutter/UI/instance_mgmt_page.dart';

// TODO: Show instance status as text instead of Last Played.

class WorldTile extends StatelessWidget {
  const WorldTile(this.world,
      {Key? key,
      this.margin = const EdgeInsets.only(left: 15, right: 15, top: 15),
      required this.client})
      : super(key: key);

  final World world;
  final EdgeInsets? margin;
  final SuperMCShare client;

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 110,
        margin: EdgeInsets.all(15),
        child: Material(
            color: Theme.of(context).colorScheme.primary,
            shadowColor: Colors.black,
            elevation: 10,
            borderRadius: BorderRadius.all(Radius.elliptical(15, 15)),
            child: InkWell(
              borderRadius: BorderRadius.all(Radius.elliptical(15, 15)),
              customBorder:
                  Border(top: BorderSide(width: 5, color: Colors.grey)),
              hoverColor: Colors.blue[100],
              onTap: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) {
                  return InstanceMgmtPageWidget(world, share: client);
                }));
              },
              child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Row(children: [
                    Flexible(
                      fit: FlexFit.tight,
                      child: Text(
                        maxLines: 2,
                        softWrap: true,
                        world.name,
                        style: GoogleFonts.rubik(
                            fontSize: 50,
                            fontWeight: FontWeight.w600,
                            color: Colors.white),
                        overflow: TextOverflow.fade,
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                            padding: EdgeInsets.zero,
                            disabledColor: Colors.white,
                            onPressed: null,
                            icon: Icon(
                              Icons.chevron_right,
                              size: 35,
                            ))
                      ],
                    )
                  ])),
            )));
  }
}
