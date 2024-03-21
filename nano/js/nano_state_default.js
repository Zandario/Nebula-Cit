/**
 * NanoStateDefaultClass inherits from NanoStateClass.
 * @extends NanoStateClass
 */
NanoStateDefaultClass.inheritsFrom(NanoStateClass);
/**
 * Instance of NanoStateDefaultClass.
 * @type {NanoStateDefaultClass}
 */
var NanoStateDefault = new NanoStateDefaultClass();

/**
 * NanoStateDefaultClass is a state class with a default key.
 * @constructor
 */
function NanoStateDefaultClass() {

	/**
	 * The key of the state.
	 * @type {string}
	 */
	this.key = 'default';

	// this.parent.constructor.call(this);

	// this.key = this.key.toLowerCase();

	/**
	 * Adds this state to the NanoStateManager.
	 */
	NanoStateManager.addState(this);
}
