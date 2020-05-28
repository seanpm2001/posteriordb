functions {

  /**
   * Return the application of tanh() elementwise to the specified
   * matrix.  // FIXME(carpenter): remove when tanh vectorized
   *
   * @param u Input matrix.
   * @return
   */
  matrix tanh_eltwise(matrix u) {
    matrix[rows(u), cols(u)] tanh_u;
    for (j in 1:cols(u))
      for (i in 1:rows(u))
        tanh_u[i, j] = tanh(u[i, j]);
    return tanh_u;
  }

  /**
   * Returns linear predictor for restricted Boltzman machine (RBM).
   * Assumes one-hidden layer with logistic sigmoid activation.
   *
   * @param x Predictors (N x M)
   * @param alpha First-layer weights (M x J)
   * @param beta Second-layer weights (J x (K - 1))
   * @return Linear predictor for output layer of RBM.
   */
  matrix rbm(matrix x, matrix alpha, matrix beta) {
    return tanh_eltwise(x * alpha) * beta;
  }
}

data {
  int<lower=0> N;              // observations (MNIST: 60K)
  int<lower=0> M;              // predictors   (MNIST: 784)
  matrix[N, M] x;              // data matrix  (MNIST: 60K x 784 = 47M)
  int<lower=2> K;              // number of categories (MNIST: 10)
  int<lower=1, upper=K> y[N];  // categories
}

transformed data{
  int<lower=1> J = 100; // number of hidden units (e.g. 100)
  vector[N] ones = rep_vector(1, N);
  matrix[N, M + 1] x1 = append_col(ones, x);
}

parameters {
  matrix[M + 1, J] alpha;
  matrix[J + 1, K - 1] beta;
}

model {
  matrix[K, N] v = append_col(ones, (append_col(ones, tanh(x1 * alpha)) * beta));
  to_vector(alpha) ~ normal(0, 2);
  to_vector(beta) ~ normal(0, 2);
  for (n in 1:N)
    y[n] ~ categorical_logit(v[n]');
}
