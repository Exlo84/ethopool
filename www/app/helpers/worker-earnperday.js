import Ember from 'ember';
import config from '../config/environment';

export default Ember.Helper.extend({
  compute(hashrates) {
    return 24 * 60 * 60 * (hashrates[0] / hashrates[1]) * 0.8 * 0.95;
  }
});
