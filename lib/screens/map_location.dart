import 'dart:async';

import 'package:active_ecommerce_flutter/other_config.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_place_picker_mb/google_maps_place_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:active_ecommerce_flutter/my_theme.dart';
import 'package:toast/toast.dart';
import 'package:active_ecommerce_flutter/custom/toast_component.dart';
import 'package:active_ecommerce_flutter/repositories/address_repository.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MapLocation extends StatefulWidget {
  final dynamic address; // make sure the address type matches your model
  const MapLocation({Key? key, required this.address}) : super(key: key);

  @override
  State<MapLocation> createState() => MapLocationState();
}

class MapLocationState extends State<MapLocation> with SingleTickerProviderStateMixin {
  PickResult? selectedPlace;
  static LatLng kInitialPosition = const LatLng(
      51.52034098371205, -0.12637399200000668); // Default to London

  @override
  void initState() {
    super.initState();

    // Use safe access with null check
    if (widget.address.location_available) {
      kInitialPosition = LatLng(widget.address.lat, widget.address.lang);
    }
  }

  Future<void> onTapPickHere(PickResult? place) async {
    if (place?.geometry?.location == null) {
      ToastComponent.showDialog(
        "Invalid location",
        gravity: Toast.center,
        duration: Toast.lengthLong,
      );
      return;
    }

    var lat = place!.geometry!.location.lat;
    var lng = place.geometry!.location.lng;

    final response = await AddressRepository().getAddressUpdateLocationResponse(
      widget.address.id,
      lat,
      lng,
    );

    ToastComponent.showDialog(
      response.message,
      gravity: Toast.center,
      duration: Toast.lengthLong,
    );
  }

  @override
  Widget build(BuildContext context) {
    // You can safely use AppLocalizations.of(context) here
    final localizations = AppLocalizations.of(context)!;
    
    return PlacePicker(
      apiKey: OtherConfig.GOOGLE_MAP_API_KEY,
      initialPosition: kInitialPosition,
      useCurrentLocation: false,
      onPlacePicked: (PickResult result) {
        selectedPlace = result;
        setState(() {});
      },
      selectedPlaceWidgetBuilder: (_, PickResult? place, state, isSearchBarFocused) {
        if (isSearchBarFocused) return Container();

        return FloatingCard(
          height: 50,
          bottomPosition: 120.0,
          leftPosition: 0.0,
          rightPosition: 0.0,
          width: 500,
          borderRadius: BorderRadius.circular(8.0),
          child: state == SearchingState.Searching
              ? Center(
                  child: Text(
                    localizations.map_location_screen_calculating,
                    style:  TextStyle(color: MyTheme.font_grey),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          place?.formattedAddress ?? "",
                          maxLines: 2,
                          style:  TextStyle(color: MyTheme.medium_grey),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: MyTheme.accent_color,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                          ),
                          child: Text(
                            localizations.map_location_screen_pick_here,
                            style: const TextStyle(color: Colors.white),
                          ),
                          onPressed: () => onTapPickHere(place),
                        ),
                      ),
                    ],
                  ),
                ),
        );
      },
      pinBuilder: (context, state) {
        return Image.asset(
          'assets/delivery_map_icon.png',
          width: state == PinState.Idle ? 88 : 80,
          height: state == PinState.Idle ? 60 : 80,
        );
      },
    );
  }
}
