import matplotlib.pyplot as plt
import numpy as np
from sympy import Rational, Matrix, sqrt

# 1. Создаем матрицу X (41x3)
col1 = [Rational(1) for _ in range(41)]

x_vals = []
for k in range(1, 42):
    x_val = Rational(-1) + Rational(k-1, 20)
    x_vals.append(x_val)

col2 = x_vals
col3 = [x**2 for x in x_vals]

X = []
for i in range(41):
    X.append([col1[i], col2[i], col3[i]])
X = Matrix(X)

# 2. Вектор Y
Y_data = [
    '0.879623284778671',
    '1.01671761177772',
    '-0.683415513974756',
    '-0.192235456905427',
    '-2.53396451133365',
    '-1.42439264880129',
    '-0.841779882659344',
    '0.0787316813930919',
    '-1.94003960790793',
    '-2.61011698115599',
    '-1.08984502736905',
    '-0.990420864256544',
    '-1.60447011579831',
    '-0.208881153367998',
    '-1.08829432039999',
    '-1.74009203307620',
    '-0.230103875539013',
    '-1.13750631984818',
    '0.663165849315322',
    '-0.0267472550042716',
    '-1.78072448989882',
    '-1.42817619199225',
    '0.498593243929413',
    '0.146938455296444',
    '-0.275223014685959',
    '0.130128663661802',
    '0.403608831970648',
    '-0.100573460718232',
    '0.139976655116730',
    '0.387435536474759',
    '0.805097762811669',
    '-0.207615419823499',
    '1.54612413550779',
    '1.97085848133636',
    '2.29017221272735',
    '0.812499784374143',
    '2.90594937119225',
    '2.36799577760497',
    '3.06555477291292',
    '2.95016280505975',
    '3.97589524100317'
]

Y = Matrix([Rational(y_str) for y_str in Y_data])

# 3. МНК
XT = X.T
XTX = XT * X
XTX_inv = XTX.inv()
XTY = XT * Y
theta_hat = XTX_inv * XTY

# Оценки параметров
theta0 = float(theta_hat[0])
theta1 = float(theta_hat[1])
theta2 = float(theta_hat[2])

print("="*70)
print("ПАРАМЕТРЫ МОДЕЛИ:")
print("="*70)
print(f"θ̂₀ = {theta0:.14f}")
print(f"θ̂₁ = {theta1:.14f}")
print(f"θ̂₂ = {theta2:.14f}")

# 4. Вычисляем RSS и норму
Y_predicted = X * theta_hat
E_hat = Y - Y_predicted
RSS = sum([e**2 for e in E_hat])
norm_E = float(sqrt(RSS))

# 5. Параметры для доверительных интервалов
n = 41
s = 3
df = n - s

# Множители
t_95 = 2.02439416377854
t_99 = 2.71155760078305
multiplier_95 = (t_95 * norm_E) / np.sqrt(df)
multiplier_99 = (t_99 * norm_E) / np.sqrt(df)

# 6. Коэффициенты α(x)
from sympy import symbols, expand, Poly
x_sym = symbols('x', real=True)
phi_x = Matrix([1, x_sym, x_sym**2])
alpha_x = (phi_x.T * XTX_inv * phi_x)[0, 0]
alpha_x_expanded = expand(alpha_x)

poly = Poly(alpha_x_expanded, x_sym)
coeffs = poly.all_coeffs()

degree = poly.degree()
if degree == 4:
    a4 = float(coeffs[0])
    a3 = float(coeffs[1])
    a2 = float(coeffs[2])
    a1 = float(coeffs[3])
    a0 = float(coeffs[4])
elif degree == 2:
    a4 = 0.0
    a3 = 0.0
    a2 = float(coeffs[0])
    a1 = float(coeffs[1])
    a0 = float(coeffs[2])

# 7. ДИ для параметров (ваши значения)
# 95%
theta0_95_lower = -1.13598005126238
theta0_95_upper = -0.37635470073084
theta1_95_lower = 1.43030770684465
theta1_95_upper = 2.28588345649423
theta2_95_lower = 1.69281839510802
theta2_95_upper = 3.31115016650722

# 99%
theta0_99_lower = -1.26490424400277
theta0_99_upper = -0.24743050799045
theta1_99_lower = 1.28509873932580
theta1_99_upper = 2.43109242401308
theta2_99_lower = 1.41815389494650
theta2_99_upper = 3.58581466666874

# 8. Подготовка данных для графика
x_obs = np.array([float(x) for x in x_vals])
y_obs = np.array([float(y) for y in Y])

x_smooth = np.linspace(-1, 1, 500)

# Полезный сигнал φ(x; θ̂)
phi_smooth = theta0 + theta1 * x_smooth + theta2 * x_smooth**2

# α(x) для гладкой кривой
alpha_smooth = a4 * x_smooth**4 + a2 * x_smooth**2 + a0

# ПРАВИЛЬНЫЕ доверительные интервалы (через α(x))
margin_95_correct = multiplier_95 * np.sqrt(alpha_smooth)
margin_99_correct = multiplier_99 * np.sqrt(alpha_smooth)

ci_95_lower_correct = phi_smooth - margin_95_correct
ci_95_upper_correct = phi_smooth + margin_95_correct

ci_99_lower_correct = phi_smooth - margin_99_correct
ci_99_upper_correct = phi_smooth + margin_99_correct

# НАИВНЫЕ границы (через границы ДИ параметров)
# Для 95%:  4 параболы (все комбинации границ)
naive_95_1 = theta0_95_lower + theta1_95_lower * x_smooth + theta2_95_lower * x_smooth**2
naive_95_2 = theta0_95_lower + theta1_95_lower * x_smooth + theta2_95_upper * x_smooth**2
naive_95_3 = theta0_95_lower + theta1_95_upper * x_smooth + theta2_95_lower * x_smooth**2
naive_95_4 = theta0_95_lower + theta1_95_upper * x_smooth + theta2_95_upper * x_smooth**2
naive_95_5 = theta0_95_upper + theta1_95_lower * x_smooth + theta2_95_lower * x_smooth**2
naive_95_6 = theta0_95_upper + theta1_95_lower * x_smooth + theta2_95_upper * x_smooth**2
naive_95_7 = theta0_95_upper + theta1_95_upper * x_smooth + theta2_95_lower * x_smooth**2
naive_95_8 = theta0_95_upper + theta1_95_upper * x_smooth + theta2_95_upper * x_smooth**2

# Находим минимум и максимум для каждой точки x
naive_95_lower = np.minimum. reduce([naive_95_1, naive_95_2, naive_95_3, naive_95_4,
                                     naive_95_5, naive_95_6, naive_95_7, naive_95_8])
naive_95_upper = np.maximum.reduce([naive_95_1, naive_95_2, naive_95_3, naive_95_4,
                                     naive_95_5, naive_95_6, naive_95_7, naive_95_8])

# Для 99%: 4 параболы
naive_99_1 = theta0_99_lower + theta1_99_lower * x_smooth + theta2_99_lower * x_smooth**2
naive_99_2 = theta0_99_lower + theta1_99_lower * x_smooth + theta2_99_upper * x_smooth**2
naive_99_3 = theta0_99_lower + theta1_99_upper * x_smooth + theta2_99_lower * x_smooth**2
naive_99_4 = theta0_99_lower + theta1_99_upper * x_smooth + theta2_99_upper * x_smooth**2
naive_99_5 = theta0_99_upper + theta1_99_lower * x_smooth + theta2_99_lower * x_smooth**2
naive_99_6 = theta0_99_upper + theta1_99_lower * x_smooth + theta2_99_upper * x_smooth**2
naive_99_7 = theta0_99_upper + theta1_99_upper * x_smooth + theta2_99_lower * x_smooth**2
naive_99_8 = theta0_99_upper + theta1_99_upper * x_smooth + theta2_99_upper * x_smooth**2

naive_99_lower = np.minimum.reduce([naive_99_1, naive_99_2, naive_99_3, naive_99_4,
                                     naive_99_5, naive_99_6, naive_99_7, naive_99_8])
naive_99_upper = np. maximum.reduce([naive_99_1, naive_99_2, naive_99_3, naive_99_4,
                                     naive_99_5, naive_99_6, naive_99_7, naive_99_8])

# 9.  ГРАФИК 1: Сравнение правильных и наивных интервалов
fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(18, 8))

# === ЛЕВЫЙ ГРАФИК:  95% ===
ax1.scatter(x_obs, y_obs, color='red', s=40, zorder=5, label='Наблюдения Y', alpha=0.7, edgecolors='darkred')
ax1.plot(x_smooth, phi_smooth, color='blue', linewidth=2.5, label='Оценка φ(x; θ̂)', zorder=4)

# Правильный 95% ДИ
ax1.fill_between(x_smooth, ci_95_lower_correct, ci_95_upper_correct, 
                 color='green', alpha=0.3, label='Правильный 95% ДИ (через α(x))', zorder=2)
ax1.plot(x_smooth, ci_95_lower_correct, color='green', linewidth=1.5, linestyle='-', alpha=0.8)
ax1.plot(x_smooth, ci_95_upper_correct, color='green', linewidth=1.5, linestyle='-', alpha=0.8)

# Наивный 95% ДИ
ax1.fill_between(x_smooth, naive_95_lower, naive_95_upper, 
                 color='orange', alpha=0.2, label='Наивный 95% ДИ (через границы θᵢ)', zorder=1)
ax1.plot(x_smooth, naive_95_lower, color='orange', linewidth=1.5, linestyle='--', alpha=0.8)
ax1.plot(x_smooth, naive_95_upper, color='orange', linewidth=1.5, linestyle='--', alpha=0.8)

ax1.set_xlabel('x', fontsize=12, fontweight='bold')
ax1.set_ylabel('Y / φ(x)', fontsize=12, fontweight='bold')
ax1.set_title('Сравнение 95% доверительных интервалов', fontsize=14, fontweight='bold')
ax1.legend(fontsize=10, loc='upper left')
ax1.grid(True, alpha=0.3)
ax1.axhline(y=0, color='k', linewidth=0.5, alpha=0.3)
ax1.axvline(x=0, color='k', linewidth=0.5, alpha=0.3)

# === ПРАВЫЙ ГРАФИК: 99% ===
ax2.scatter(x_obs, y_obs, color='red', s=40, zorder=5, label='Наблюдения Y', alpha=0.7, edgecolors='darkred')
ax2.plot(x_smooth, phi_smooth, color='blue', linewidth=2.5, label='Оценка φ(x; θ̂)', zorder=4)

# Правильный 99% ДИ
ax2.fill_between(x_smooth, ci_99_lower_correct, ci_99_upper_correct, 
                 color='purple', alpha=0.3, label='Правильный 99% ДИ (через α(x))', zorder=2)
ax2.plot(x_smooth, ci_99_lower_correct, color='purple', linewidth=1.5, linestyle='-', alpha=0.8)
ax2.plot(x_smooth, ci_99_upper_correct, color='purple', linewidth=1.5, linestyle='-', alpha=0.8)

# Наивный 99% ДИ
ax2.fill_between(x_smooth, naive_99_lower, naive_99_upper, 
                 color='orange', alpha=0.2, label='Наивный 99% ДИ (через границы θᵢ)', zorder=1)
ax2.plot(x_smooth, naive_99_lower, color='orange', linewidth=1.5, linestyle='--', alpha=0.8)
ax2.plot(x_smooth, naive_99_upper, color='orange', linewidth=1.5, linestyle='--', alpha=0.8)

ax2.set_xlabel('x', fontsize=12, fontweight='bold')
ax2.set_ylabel('Y / φ(x)', fontsize=12, fontweight='bold')
ax2.set_title('Сравнение 99% доверительных интервалов', fontsize=14, fontweight='bold')
ax2.legend(fontsize=10, loc='upper left')
ax2.grid(True, alpha=0.3)
ax2.axhline(y=0, color='k', linewidth=0.5, alpha=0.3)
ax2.axvline(x=0, color='k', linewidth=0.5, alpha=0.3)

plt.tight_layout()
plt.savefig('comparison_intervals.png', dpi=300, bbox_inches='tight')
print("График сравнения сохранен:  comparison_intervals.png")
plt.show()

# 10. ГРАФИК 2: Только наивный подход (4 параболы)
fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(18, 8))

# === 95% (4 крайние параболы) ===
ax1.scatter(x_obs, y_obs, color='red', s=40, zorder=5, label='Наблюдения Y', alpha=0.7, edgecolors='darkred')
ax1.plot(x_smooth, phi_smooth, color='blue', linewidth=2.5, label='Оценка φ(x; θ̂)', zorder=4)

# Рисуем все 8 парабол
ax1.plot(x_smooth, naive_95_1, color='orange', linewidth=1, alpha=0.5, linestyle='--')
ax1.plot(x_smooth, naive_95_2, color='orange', linewidth=1, alpha=0.5, linestyle='--')
ax1.plot(x_smooth, naive_95_3, color='orange', linewidth=1, alpha=0.5, linestyle='--')
ax1.plot(x_smooth, naive_95_4, color='orange', linewidth=1, alpha=0.5, linestyle='--')
ax1.plot(x_smooth, naive_95_5, color='orange', linewidth=1, alpha=0.5, linestyle='--')
ax1.plot(x_smooth, naive_95_6, color='orange', linewidth=1, alpha=0.5, linestyle='--')
ax1.plot(x_smooth, naive_95_7, color='orange', linewidth=1, alpha=0.5, linestyle='--')
ax1.plot(x_smooth, naive_95_8, color='orange', linewidth=1, alpha=0.5, linestyle='--', label='Граничные параболы (95%)')

# Огибающие
ax1.plot(x_smooth, naive_95_lower, color='darkred', linewidth=2, linestyle='-', label='Нижняя огибающая')
ax1.plot(x_smooth, naive_95_upper, color='darkred', linewidth=2, linestyle='-', label='Верхняя огибающая')
ax1.fill_between(x_smooth, naive_95_lower, naive_95_upper, color='yellow', alpha=0.2)

ax1.set_xlabel('x', fontsize=12, fontweight='bold')
ax1.set_ylabel('Y / φ(x)', fontsize=12, fontweight='bold')
ax1.set_title('Наивный 95% ДИ:  все граничные параболы', fontsize=14, fontweight='bold')
ax1.legend(fontsize=9, loc='upper left')
ax1.grid(True, alpha=0.3)

# === 99% (4 крайние параболы) ===
ax2.scatter(x_obs, y_obs, color='red', s=40, zorder=5, label='Наблюдения Y', alpha=0.7, edgecolors='darkred')
ax2.plot(x_smooth, phi_smooth, color='blue', linewidth=2.5, label='Оценка φ(x; θ̂)', zorder=4)

# Рисуем все 8 парабол
ax2.plot(x_smooth, naive_99_1, color='cyan', linewidth=1, alpha=0.5, linestyle='--')
ax2.plot(x_smooth, naive_99_2, color='cyan', linewidth=1, alpha=0.5, linestyle='--')
ax2.plot(x_smooth, naive_99_3, color='cyan', linewidth=1, alpha=0.5, linestyle='--')
ax2.plot(x_smooth, naive_99_4, color='cyan', linewidth=1, alpha=0.5, linestyle='--')
ax2.plot(x_smooth, naive_99_5, color='cyan', linewidth=1, alpha=0.5, linestyle='--')
ax2.plot(x_smooth, naive_99_6, color='cyan', linewidth=1, alpha=0.5, linestyle='--')
ax2.plot(x_smooth, naive_99_7, color='cyan', linewidth=1, alpha=0.5, linestyle='--')
ax2.plot(x_smooth, naive_99_8, color='cyan', linewidth=1, alpha=0.5, linestyle='--', label='Граничные параболы (99%)')

# Огибающие
ax2.plot(x_smooth, naive_99_lower, color='darkblue', linewidth=2, linestyle='-', label='Нижняя огибающая')
ax2.plot(x_smooth, naive_99_upper, color='darkblue', linewidth=2, linestyle='-', label='Верхняя огибающая')
ax2.fill_between(x_smooth, naive_99_lower, naive_99_upper, color='lightblue', alpha=0.2)

ax2.set_xlabel('x', fontsize=12, fontweight='bold')
ax2.set_ylabel('Y / φ(x)', fontsize=12, fontweight='bold')
ax2.set_title('Наивный 99% ДИ: все граничные параболы', fontsize=14, fontweight='bold')
ax2.legend(fontsize=9, loc='upper left')
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('naive_parabolas.png', dpi=300, bbox_inches='tight')
print("График с параболами сохранен: naive_parabolas.png")
plt.show()

# 11. Статистика
print("\n" + "="*70)
print("СРАВНЕНИЕ ШИРИНЫ ИНТЕРВАЛОВ:")
print("="*70)

width_95_correct = np.mean(ci_95_upper_correct - ci_95_lower_correct)
width_95_naive = np.mean(naive_95_upper - naive_95_lower)
width_99_correct = np.mean(ci_99_upper_correct - ci_99_lower_correct)
width_99_naive = np.mean(naive_99_upper - naive_99_lower)

print(f"\n95% ДИ:")
print(f"  Правильный (средняя ширина): {width_95_correct:.4f}")
print(f"  Наивный (средняя ширина):     {width_95_naive:.4f}")
print(f"  Разница: {width_95_naive - width_95_correct:.4f} ({(width_95_naive/width_95_correct - 1)*100:.1f}% шире)")

print(f"\n99% ДИ:")
print(f"  Правильный (средняя ширина): {width_99_correct:.4f}")
print(f"  Наивный (средняя ширина):     {width_99_naive:.4f}")
print(f"  Разница: {width_99_naive - width_99_correct:.4f} ({(width_99_naive/width_99_correct - 1)*100:.1f}% шире)")
print("="*70)