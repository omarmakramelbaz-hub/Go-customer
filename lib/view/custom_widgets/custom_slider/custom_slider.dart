import 'package:carousel_slider/carousel_controller.dart' as carousel_controller;
import 'package:carousel_slider/carousel_slider.dart' as carousel_slider;
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../helpers/theme/app_colors.dart';
import '../custom_image/custom_network_image.dart';

class SliderArguments {
  String? url;
  Widget? child;
  void Function()? onTap;

  SliderArguments({this.url, this.child, this.onTap});
}

class CustomSlider extends StatefulWidget {
  final List<SliderArguments> sliderArguments;
  final bool autoPlay;
  final bool hasDots;
  final bool isDotsOnContent;
  final bool hasZoom;
  final double aspectRatio;
  final double radius;
  final double? width;
  final BoxFit fit;
  final Color? color;

  const CustomSlider({
    super.key,
    required this.sliderArguments,
    this.autoPlay = true,
    this.hasDots = true,
    this.isDotsOnContent = true,
    this.hasZoom = false,
    this.aspectRatio = 333 / 158,
    this.radius = 15,
    this.fit = BoxFit.cover,
    this.color,
    this.width,
  });

  @override
  State<CustomSlider> createState() => _CustomSliderState();
}

class _CustomSliderState extends State<CustomSlider> {
  int _index = 0;
  late carousel_controller.CarouselSliderController _carouselController;
  @override
  void initState() {
    _carouselController = carousel_controller.CarouselSliderController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        carousel_slider.CarouselSlider(
          carouselController: _carouselController,
          items: widget.sliderArguments.map((item) {
            return GestureDetector(
              onTap: item.onTap,
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: Container(
                  width: widget.width ?? double.infinity,
                  margin: EdgeInsets.only(
                    bottom: (!widget.isDotsOnContent && widget.hasDots) ? 20.0 : 0.0,
                  ),
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: widget.color ?? AppColors.mainAppColor,
                    borderRadius: BorderRadius.circular(widget.radius),
                  ),
                  child: item.child ??
                      CustomNetworkImage(
                        hasZoom: widget.hasZoom,
                        radius: 25,
                        imageUrl: item.url!,
                        width: double.infinity,
                        height: 190,
                        fit: widget.fit,
                      ),
                ),
              ),
            );
          }).toList(),
          options: carousel_slider.CarouselOptions(
            aspectRatio: widget.aspectRatio,
            autoPlayAnimationDuration: const Duration(seconds: 2),
            autoPlay: widget.autoPlay,
            viewportFraction: 1,
            onPageChanged: (i, _) {
              setState(() {
                _index = i;
              });
            },
          ),
        ),
        if (widget.hasDots) ...{
          Positioned(
            bottom: 7,
            right: 0,
            left: 0,
            child: Center(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: AnimatedSmoothIndicator(
                  activeIndex: _index,
                  count: widget.sliderArguments.length,
                  effect: ExpandingDotsEffect(
                    dotColor: AppColors.greyColor,
                    activeDotColor: widget.color ?? AppColors.mainAppColor,
                    dotHeight: 7,
                    dotWidth: 7,
                  ),
                  onDotClicked: (i) {
                    _carouselController.animateToPage(i);
                  },
                ),
              ),
            ),
          ),
        },
      ],
    );
  }
}
