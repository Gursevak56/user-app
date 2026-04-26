import 'package:flutter/material.dart';
import 'package:food_delivery/common/color_extension.dart';
import 'package:food_delivery/common_widget/round_button.dart';
import 'package:food_delivery/common_widget/round_textfield.dart';
import 'package:google_fonts/google_fonts.dart';

class AddCardView extends StatefulWidget {
  const AddCardView({super.key});

  @override
  State<AddCardView> createState() => _AddCardViewState();
}

class _AddCardViewState extends State<AddCardView> {
  TextEditingController txtCardNumber = TextEditingController();
  TextEditingController txtCardMonth = TextEditingController();
  TextEditingController txtCardYear = TextEditingController();
  TextEditingController txtCardCode = TextEditingController();
  TextEditingController txtFirstName = TextEditingController();
  TextEditingController txtLastName = TextEditingController();
  bool isAnyTime = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 25),
      decoration: BoxDecoration(
        color: TColor.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Add Credit/Debit Card",
                style: GoogleFonts.plusJakartaSans(
                  color: TColor.primaryText,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(
                  Icons.close_rounded,
                  color: TColor.primaryText,
                  size: 24,
                ),
              )
            ],
          ),
          Divider(
            color: TColor.border,
            height: 1,
            thickness: 1,
          ),
          const SizedBox(height: 20),
          RoundTextfield(
            hintText: "Card Number",
            controller: txtCardNumber,
            keyboardType: TextInputType.number,
            left: Icon(Icons.credit_card_rounded, color: TColor.placeholder, size: 20),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                "Expiry",
                style: GoogleFonts.plusJakartaSans(
                  color: TColor.primaryText,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              SizedBox(
                width: 100,
                child: RoundTextfield(
                  hintText: "MM",
                  controller: txtCardMonth,
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 16),
              SizedBox(
                width: 100,
                child: RoundTextfield(
                  hintText: "YYYY",
                  controller: txtCardYear,
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          RoundTextfield(
            hintText: "Card Security Code (CVV)",
            controller: txtCardCode,
            keyboardType: TextInputType.number,
            obscureText: true,
            left: Icon(Icons.lock_rounded, color: TColor.placeholder, size: 20),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: RoundTextfield(
                  hintText: "First Name",
                  controller: txtFirstName,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: RoundTextfield(
                  hintText: "Last Name",
                  controller: txtLastName,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Text(
                  "You can remove this card at anytime",
                  style: GoogleFonts.plusJakartaSans(
                    color: TColor.secondaryText,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Switch(
                value: isAnyTime,
                activeColor: TColor.primary,
                activeTrackColor: TColor.primary.withOpacity(0.3),
                onChanged: (newVal) {
                  setState(() {
                    isAnyTime = newVal;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 25),
          RoundButton(
            title: "Add Card",
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 15),
        ],
      ),
    );
  }
}
