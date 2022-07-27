import 'dart:math';

class MathProblem {
  late double left;
  late double right;
  late MathOperator operator;

  String get humanReadable {
    if (operator == MathOperator.addition) {
      return "$left+$right";
    } else if (operator == MathOperator.subtraction) {
      return "$left-$right";
    } else if (operator == MathOperator.multiplication) {
      return "${left}x$right";
    }
    return "$left/$right";
  }

  MathProblem(this.left, this.operator, this.right);

  String solve() {
    if (operator == MathOperator.addition) {
      return (left + right).toStringAsFixed(1);
    } else if (operator == MathOperator.subtraction) {
      return (left - right).toStringAsFixed(1);
    } else if (operator == MathOperator.multiplication) {
      return (left * right).toStringAsFixed(1);
    }
    return (left / right).toStringAsFixed(1);
  }

  bool check(String potentialAnswer) {
    if (solve() == potentialAnswer) {
      return true;
    }
    return false;
  }

  MathProblem.random() {
    final rng = Random();
    left = double.parse((rng.nextDouble() * 10).toStringAsFixed(1));
    right = double.parse((rng.nextDouble() * 10).toStringAsFixed(1));
    operator = MathOperator.values[rng.nextInt(4)];
  }
}

enum MathOperator { addition, subtraction, multiplication, division }
