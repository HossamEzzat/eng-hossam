enum JourneyMilestone {
  registered,
  attended,
  certificate,
  review,
  completed,
}

enum JourneyStepVisual { completed, current, locked }

class StudentJourney {
  const StudentJourney({
    required this.registrationCompleted,
    required this.attendanceConfirmed,
    required this.certificateIssued,
    required this.certificateDownloaded,
    required this.reviewSubmitted,
  });

  final bool registrationCompleted;
  final bool attendanceConfirmed;
  final bool certificateIssued;
  final bool certificateDownloaded;
  final bool reviewSubmitted;

  bool get isFullyComplete => reviewSubmitted;

  factory StudentJourney.fromRegistration({
    required bool hasRegistration,
    required bool attendanceConfirmed,
    required bool certificateDownloaded,
    required bool reviewSubmitted,
    bool? certificateIssued,
  }) {
    return StudentJourney(
      registrationCompleted: hasRegistration,
      attendanceConfirmed: attendanceConfirmed,
      certificateIssued: certificateIssued ?? attendanceConfirmed,
      certificateDownloaded: certificateDownloaded,
      reviewSubmitted: reviewSubmitted,
    );
  }

  JourneyStepVisual stateFor(JourneyMilestone milestone) {
    switch (milestone) {
      case JourneyMilestone.registered:
        return registrationCompleted
            ? JourneyStepVisual.completed
            : JourneyStepVisual.locked;
      case JourneyMilestone.attended:
        if (attendanceConfirmed) return JourneyStepVisual.completed;
        if (registrationCompleted) return JourneyStepVisual.current;
        return JourneyStepVisual.locked;
      case JourneyMilestone.certificate:
        if (certificateDownloaded) return JourneyStepVisual.completed;
        // Available immediately after registration — no attendance wait.
        if (registrationCompleted) return JourneyStepVisual.current;
        return JourneyStepVisual.locked;
      case JourneyMilestone.review:
        if (reviewSubmitted) return JourneyStepVisual.completed;
        if (registrationCompleted) return JourneyStepVisual.current;
        return JourneyStepVisual.locked;
      case JourneyMilestone.completed:
        if (reviewSubmitted) return JourneyStepVisual.completed;
        return JourneyStepVisual.locked;
    }
  }

  JourneyMilestone get currentMilestone {
    if (!registrationCompleted) return JourneyMilestone.registered;
    if (!certificateDownloaded) return JourneyMilestone.certificate;
    if (!reviewSubmitted) return JourneyMilestone.review;
    return JourneyMilestone.completed;
  }
}
