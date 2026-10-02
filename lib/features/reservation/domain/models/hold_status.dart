/// Lifecycle states for the 2-minute emergency hospital hold protocol.
enum HoldLifecycleState {
  pending('REQUEST PENDING • 2-MIN PROTOCOL'),
  accepted('BED HOLD CONFIRMED • LOCKED'),
  rejected('REQUEST DECLINED BY HOSPITAL'),
  timedOut('NO RESPONSE • HOLD EXPIRED'),
  fallbackTransition('CONTACTING NEXT CANDIDATE');

  const HoldLifecycleState(this.label);
  final String label;

  bool get isPending => this == HoldLifecycleState.pending;
  bool get isAccepted => this == HoldLifecycleState.accepted;
  bool get isRejected => this == HoldLifecycleState.rejected;
  bool get isTimedOut => this == HoldLifecycleState.timedOut;
  bool get isFallbackTransition => this == HoldLifecycleState.fallbackTransition;
}
