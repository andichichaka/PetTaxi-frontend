enum ServiceType: String, CaseIterable, Identifiable {
    case dailyWalking = "Daily Walking"
    case weeklyWalking = "Weekly Walking"
    case dailySitting = "Daily Sitting"
    case weeklySitting = "Weekly Sitting"
    case other = "Other"

    var id: String { rawValue }
}

enum AnimalSize: String, CaseIterable, Identifiable {
    case mini = "Mini (0-5kg)"
    case small = "Small (5-10kg)"
    case medium = "Medium (10-15kg)"
    case large = "Large (15-25kg)"
    case other = "Other"

    var id: String { rawValue }
}

enum AnimalType: String, CaseIterable, Identifiable {
    case dog = "Dog"
    case cat = "Cat"
    case both = "Both"

    var id: String { rawValue }
}
