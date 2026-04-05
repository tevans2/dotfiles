#proof #ms246 #linear-algebra #chp1

# Proof

## **Statement**

Let $a_1, a_2, \ldots, a_m$ be a set of **orthogonal non-zero vectors**,
and let $b$ be any other vector with the same number of elements.

Then $b$ can be **uniquely expressed** as:

$$
b = b_1 + b_2
$$

where:

- $b_1$ is **dependent** on the set ${ a_1, a_2, \ldots, a_m }$,

- $b_2$ is **orthogonal** to every vector in that set, i.e.
    $a_k' b_2 = 0$ for all $k = 1, 2, \ldots, m$.


---

![[testimage.png|100]]


## **Proof (Step by Step)**

### 1. Start with the orthogonal set

Since $a_1, a_2, \ldots, a_m$ are all orthogonal and non-zero, we can write:

$$
b = \sum_{j=1}^{m} \frac{a_j' b}{a_j' a_j} a_j + \left( b - \sum_{j=1}^{m} \frac{a_j' b}{a_j' a_j} a_j \right)
$$

Let:

$$
b_1 = \sum_{j=1}^{m} \frac{a_j' b}{a_j' a_j} a_j, \quad
b_2 = b - \sum_{j=1}^{m} \frac{a_j' b}{a_j' a_j} a_j
$$

Hence:

$$
b = b_1 + b_2
$$

---

### 2. Show that $b_2$ is orthogonal to each $a_k$

For any $k = 1, 2, \ldots, m$:

$$
a_k' b_2 = a_k' \left( b - \sum_{j=1}^{m} \frac{a_j' b}{a_j' a_j} a_j \right)
$$

Using orthogonality ($a_k' a_j = 0$ for $k \neq j$):

$$
a_k' b_2 = a_k' b - \frac{a_k' b}{a_k' a_k} a_k' a_k = 0
$$

✅ Thus, $b_2$ is orthogonal to **every** $a_k$.

---

### 3. Show uniqueness of the decomposition

Suppose:

$$
b = \sum_{i=1}^{m} c_i a_i + b_2, \quad \text{with } a_i' b_2 = 0 \text{ for all } i.
$$

Multiply both sides by $a_j'$:

$$
a_j' b = \sum_{i=1}^{m} c_i a_j' a_i + a_j' b_2
$$

Since the $a_i$ are orthogonal:

$$
a_j' b = c_j a_j' a_j
$$

Hence:

$$
c_j = \frac{a_j' b}{a_j' a_j}
$$

✅ Each coefficient $c_j$ is **uniquely determined** by $a_j$ and $b$.

---

### 4. Final expressions

The decomposition is therefore:

$$
\boxed{
\begin{aligned}
b_1 &= \sum_{j=1}^{m} \frac{a_j' b}{a_j' a_j} a_j \\
b_2 &= b - \sum_{j=1}^{m} \frac{a_j' b}{a_j' a_j} a_j \\
b &= b_1 + b_2
\end{aligned}
}
$$

---

## **🧠 Summary**

- $b_1$ is the **projection** of $b$ onto the subspace spanned by ${ a_1, a_2, \ldots, a_m }$.

- $b_2$ is the **component of $b$ orthogonal** to that subspace.

- Each scalar $c_j = \dfrac{a_j' b}{a_j' a_j}$ gives how much of $a_j$ contributes to $b_1$.

- The decomposition is **unique**.


---

## **Visualisation Insight**

Think of ${ a_1, \ldots, a_m }$ as the coordinate axes of a smaller “subspace.”
The vector $b_1$ lies _within_ this subspace, and $b_2$ is the “shadow” of $b$ that lies _perpendicular_ to it.

