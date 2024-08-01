import 'package:flutter/material.dart';
import 'package:idea_docket/theme/colours.dart';

void showSnackBarError(BuildContext context, String errorMessage) {
  ScaffoldMessenger.of(context)
      .showSnackBar(
        SnackBar(
          content: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                height: 80,
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 143, 22, 13),
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 48,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Error",
                            style: TextStyle(
                              fontFamily: "GilroyBold",
                              fontSize: 18,
                              color: whiteUsed,
                            ),
                            maxLines: 1,
                          ),
                          const Spacer(),
                          Text(
                            errorMessage,
                            style: const TextStyle(
                              fontFamily: "Gilroy",
                              fontSize: 12,
                              color: whiteUsed,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              const Positioned(
                left: 15,
                top: 20,
                child: Icon(
                  Icons.error,
                  size: 35,
                  color: Color.fromARGB(255, 231, 33, 19),
                ),
              ),
              const Positioned(
                left: 0,
                top: -18,
                child: Icon(
                  Icons.circle,
                  size: 40,
                  color: Color.fromARGB(255, 187, 37, 26),
                ),
              ),
              const Positioned(
                left: 8,
                top: -12,
                child: Icon(
                  Icons.close,
                  size: 24,
                  color: whiteUsed,
                ),
              ),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      )
      .closed
      .then((value) => ScaffoldMessenger.of(context).clearSnackBars());
}

void showSnackBarAccountError(
    BuildContext context, String errorHead, String errorMessage) {
  ScaffoldMessenger.of(context)
      .showSnackBar(
        SnackBar(
          content: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                height: 80,
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 90, 86, 86),
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 48,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            errorHead,
                            style: const TextStyle(
                                fontFamily: "GilroyBold",
                                fontSize: 18,
                                color: blackUsed),
                            maxLines: 1,
                          ),
                          const Spacer(),
                          Text(
                            errorMessage,
                            style: const TextStyle(
                              fontFamily: "Gilroy",
                              fontSize: 12,
                              color: blackUsed,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              const Positioned(
                left: 15,
                top: 20,
                child: Icon(
                  Icons.error,
                  size: 35,
                  color: Color.fromARGB(255, 6, 6, 6),
                ),
              ),
              const Positioned(
                left: 0,
                top: -18,
                child: Icon(
                  Icons.circle,
                  size: 40,
                  color: Color.fromARGB(255, 88, 84, 84),
                ),
              ),
              const Positioned(
                left: 8,
                top: -12,
                child: Icon(
                  Icons.close,
                  size: 24,
                  color: whiteUsed,
                ),
              ),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      )
      .closed
      .then((value) => ScaffoldMessenger.of(context).clearSnackBars());
}

void showSnackBarSuccess(BuildContext context, String successMessage) {
  ScaffoldMessenger.of(context)
      .showSnackBar(
        SnackBar(
          content: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                height: 80,
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 20, 143, 13),
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 48,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Success",
                            style: TextStyle(
                              fontFamily: "GilroyBold",
                              fontSize: 18,
                              color: whiteUsed,
                            ),
                            maxLines: 1,
                          ),
                          const Spacer(),
                          Text(
                            successMessage,
                            style: const TextStyle(
                              fontFamily: "Gilroy",
                              fontSize: 12,
                              color: whiteUsed,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              const Positioned(
                left: 15,
                top: 20,
                child: Icon(
                  Icons.check_box,
                  size: 35,
                  color: Color.fromARGB(255, 45, 187, 26),
                ),
              ),
              const Positioned(
                left: 0,
                top: -18,
                child: Icon(
                  Icons.circle,
                  size: 40,
                  color: Color.fromARGB(255, 45, 187, 26),
                ),
              ),
              const Positioned(
                left: 8,
                top: -12,
                child: Icon(
                  Icons.close,
                  size: 24,
                  color: whiteUsed,
                ),
              ),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      )
      .closed
      .then((value) => ScaffoldMessenger.of(context).clearSnackBars());
}

void showSnackBarWarning(BuildContext context, String warningMessage) {
  ScaffoldMessenger.of(context)
      .showSnackBar(
        SnackBar(
          content: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                height: 80,
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 231, 182, 5),
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 48,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Warning!",
                            style: TextStyle(
                              fontFamily: "GilroyBold",
                              fontSize: 18,
                              color: whiteUsed,
                            ),
                            maxLines: 1,
                          ),
                          const Spacer(),
                          Text(
                            warningMessage,
                            style: const TextStyle(
                              fontFamily: "GilroyBold",
                              fontSize: 14,
                              color: whiteUsed,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              const Positioned(
                left: 15,
                top: 20,
                child: Icon(
                  Icons.warning,
                  size: 35,
                  color: whiteUsed,
                ),
              ),
              const Positioned(
                left: 0,
                top: -18,
                child: Icon(
                  Icons.circle,
                  size: 40,
                  color: Color.fromARGB(255, 224, 149, 10),
                ),
              ),
              const Positioned(
                left: 8,
                top: -12,
                child: Icon(
                  Icons.close,
                  size: 24,
                  color: whiteUsed,
                ),
              ),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      )
      .closed
      .then((value) => ScaffoldMessenger.of(context).clearSnackBars());
}
