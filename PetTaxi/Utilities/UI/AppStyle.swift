import SwiftUI

struct AppStyle {

    struct Colors {
        static let base = Color("Color")        // dark green
        static let light = Color("Color 1")     // white
        static let secondary = Color("Color 2") // mid green
        static let accent = Color("Color 3")    // bright green
    }

    struct Fonts {
        static func vollkornBold(_ size: CGFloat) -> Font {
            .custom("Vollkorn-Bold", size: size)
        }

        static func vollkornBoldItalic(_ size: CGFloat) -> Font {
            .custom("Vollkorn-BoldItalic", size: size)
        }

        static func vollkornItalic(_ size: CGFloat) -> Font {
            .custom("Vollkorn-Italic", size: size)
        }

        static func vollkornMedium(_ size: CGFloat) -> Font {
            .custom("Vollkorn-Medium", size: size)
        }

        static func vollkornMediumItalic(_ size: CGFloat) -> Font {
            .custom("Vollkorn-MediumItalic", size: size)
        }

        static func vollkornRegular(_ size: CGFloat) -> Font {
            .custom("Vollkorn-Regular", size: size)
        }

        static func vollkornSemibold(_ size: CGFloat) -> Font {
            .custom("Vollkorn-Semibold", size: size)
        }

        static func vollkornSemiboldItalic(_ size: CGFloat) -> Font {
            .custom("Vollkorn-SemiboldItalic", size: size)
        }

        static func lilita(_ size: CGFloat) -> Font {
            .custom("LilitaOne", size: size)
        }

        static func modak(_ size: CGFloat) -> Font {
            .custom("Modak-Regular", size: size)
        }
    }
}
