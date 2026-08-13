enum BusinessOnboardingStep {
  basicInfo,
  contactInfo,
  additionalInfo,
}

class BusinessOnboardingState {
  const BusinessOnboardingState({
    this.currentStep = BusinessOnboardingStep.basicInfo,
  });

  final BusinessOnboardingStep currentStep;

  BusinessOnboardingState copyWith({
    BusinessOnboardingStep? currentStep,
  }) {
    return BusinessOnboardingState(
      currentStep: currentStep ?? this.currentStep,
    );
  }
}