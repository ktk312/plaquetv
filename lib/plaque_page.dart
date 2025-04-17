import 'package:flutter/material.dart';
import 'package:kosher_dart/kosher_dart.dart';
import 'package:plaquetvapp/custom_card.dart';
import 'package:plaquetvapp/plaque_model.dart';

class PlaquePage extends StatefulWidget {
  const PlaquePage({
    super.key,
    required this.plaqueList,
    required this.hebrewDateFormatter,
  });

  final List<PlaqueModel> plaqueList;
  final hebrewDateFormatter;
  @override
  State<PlaquePage> createState() => _PlaquePageState();
}

class _PlaquePageState extends State<PlaquePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: CustomCard(
      child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: [
              const Text(
                'Plaque List',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
              widget.plaqueList.isEmpty
                  ? const Text('No Plaques found')
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              const Text(
                                'Male List',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              Table(
                                defaultColumnWidth: const FlexColumnWidth(),
                                border: TableBorder.all(
                                    color: Colors.white,
                                    style: BorderStyle.solid,
                                    width: 2),
                                children: [
                                  const TableRow(children: [
                                    Column(children: [
                                      Text('Name',
                                          style: TextStyle(
                                            fontSize: 20.0,
                                            color: Colors.white,
                                          ))
                                    ]),
                                    Column(children: [
                                      Text('Date',
                                          style: TextStyle(
                                            fontSize: 20.0,
                                            color: Colors.white,
                                          ))
                                    ]),
                                  ]),
                                  for (var plaque in widget.plaqueList)
                                    if (plaque.gender.toUpperCase() == 'MALE')
                                      TableRow(children: [
                                        Column(
                                          children: [
                                            Text(plaque.hebruname,
                                                style: const TextStyle(
                                                  fontSize: 16.0,
                                                  color: Colors.white,
                                                ))
                                          ],
                                        ),
                                        Column(
                                          children: [
                                            Text(
                                                widget.hebrewDateFormatter
                                                    .format(
                                                        JewishDate.fromDateTime(
                                                            DateTime.tryParse(
                                                                plaque.dod)!)),
                                                style: const TextStyle(
                                                  fontSize: 16.0,
                                                  color: Colors.white,
                                                ))
                                          ],
                                        ),
                                      ])
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const Text(
                                'Female List',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              Table(
                                defaultColumnWidth: const FlexColumnWidth(),
                                border: TableBorder.all(
                                    color: Colors.white,
                                    style: BorderStyle.solid,
                                    width: 2),
                                children: [
                                  const TableRow(children: [
                                    Column(children: [
                                      Text('Name',
                                          style: TextStyle(
                                            fontSize: 20.0,
                                            color: Colors.white,
                                          ))
                                    ]),
                                    Column(children: [
                                      Text('Date',
                                          style: TextStyle(
                                            fontSize: 20.0,
                                            color: Colors.white,
                                          ))
                                    ]),
                                  ]),
                                  for (var plaque in widget.plaqueList)
                                    if (plaque.gender.toUpperCase() == 'FEMALE')
                                      TableRow(children: [
                                        Column(
                                          children: [
                                            Text(plaque.hebruname,
                                                style: const TextStyle(
                                                  fontSize: 16.0,
                                                  color: Colors.white,
                                                ))
                                          ],
                                        ),
                                        Column(
                                          children: [
                                            Text(
                                                widget.hebrewDateFormatter
                                                    .format(
                                                        JewishDate.fromDateTime(
                                                            DateTime.tryParse(
                                                                plaque.dod)!)),
                                                style: const TextStyle(
                                                  fontSize: 16.0,
                                                  color: Colors.white,
                                                ))
                                          ],
                                        ),
                                      ])
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
            ],
          )),
    ));
  }
}
