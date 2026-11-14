const orderTrackingSteps = <String>[
  'placed',
  'preparing',
  'out_for_delivery',
  'delivered',
];

const orderTrackingStepLabels = <String, String>{
  'placed': 'Order Placed',
  'preparing': 'Preparing',
  'out_for_delivery': 'Out for Delivery',
  'delivered': 'Delivered',
};

const orderTrackingStepLabelsAr = <String, String>{
  'placed': 'تم استلام الطلب',
  'preparing': 'قيد التحضير',
  'out_for_delivery': 'في الطريق إليك',
  'delivered': 'تم التوصيل',
};

int trackingStepIndex(String trackingStep) {
  final index = orderTrackingSteps.indexOf(trackingStep);
  return index < 0 ? 1 : index;
}

String? nextTrackingStep(String trackingStep) {
  final index = orderTrackingSteps.indexOf(trackingStep);
  if (index < 0 || index >= orderTrackingSteps.length - 1) {
    return null;
  }
  return orderTrackingSteps[index + 1];
}

String resolveTrackingStep({String? trackingStep, String? legacyStatus}) {
  if (trackingStep != null &&
      trackingStep.isNotEmpty &&
      orderTrackingSteps.contains(trackingStep)) {
    return trackingStep;
  }
  if (legacyStatus == 'قيد التحضير') {
    return 'preparing';
  }
  return 'preparing';
}

String statusLabelForStep(String trackingStep) {
  return orderTrackingStepLabelsAr[trackingStep] ??
      orderTrackingStepLabels[trackingStep] ??
      trackingStep;
}
