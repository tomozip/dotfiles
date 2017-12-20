module.exports = function load() {
  console.log('\n Loading tests (' + this.tests.length.toString().cyan + ')\n');
  Promise.all(this.tests.map(a => a.run()))
    .then(this.complete)
    .catch(e => console.log(e));
};