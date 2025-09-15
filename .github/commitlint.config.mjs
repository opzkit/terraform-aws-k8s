export default {
  extends: ['@commitlint/config-conventional'],
  /*
   * Any rules defined here will override rules from @commitlint/config-conventional
   */
  rules: {
    'header-max-length': [2, 'always', 105],
    'body-max-line-length': [2, 'always', 200],
  },
};
