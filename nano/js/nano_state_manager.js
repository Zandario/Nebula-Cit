/**
 * NanoStateManager handles data from the server and uses it to render templates.
 * @constructor
 */
NanoStateManager = function () {
	/**
	 * Is set to true when all of this ui's templates have been processed/rendered.
	 * @type {boolean}
	 */
	var _isInitialised = false;

	/**
	 * The data for this ui.
	 * @type {Object}
	 */
	var _data = null;

	/**
	 * An array of callbacks which are called when new data arrives, before it is processed.
	 * @type {Object.<string, Function>}
	 */
	var _beforeUpdateCallbacks = {};

	/**
	 * An array of callbacks which are called when new data arrives, after it is processed.
	 * @type {Object.<string, Function>}
	 */
	var _afterUpdateCallbacks = {};

	/**
	 * An array of state objects, these can be used to provide custom javascript logic.
	 * @type {Object.<string, NanoStateClass>}
	 */
	var _states = {};

	/**
	 * The current state.
	 * @type {NanoStateClass}
	 */
	var _currentState = null;

	/**
	 * The init function is called when the ui has loaded.
	 * This function sets up the templates and base functionality.
	 */
	var init = function () {
		// We store initialData and templateData in the body tag, it's as good a place as any
		_data = $('body').data('initialData');

		if (_data == null || !_data.hasOwnProperty('config') || !_data.hasOwnProperty('data')) {
			alert('Error: Initial data did not load correctly.');
		}

		var stateKey = 'default';
		if (_data['config'].hasOwnProperty('stateKey') && _data['config']['stateKey']) {
			stateKey = _data['config']['stateKey'].toLowerCase();
		}

		NanoStateManager.setCurrentState(stateKey);

		$(document).on('templatesLoaded', function () {
			doUpdate(_data);

			_isInitialised = true;
		});
	};

	/**
	 * Receive update data from the server.
	 * @param {string} jsonString - The JSON string received from the server.
	 */
	var receiveUpdateData = function (jsonString) {
		var updateData;

		//alert("recieveUpdateData called." + "<br>Type: " + typeof jsonString); //debug hook
		try {
			// parse the JSON string from the server into a JSON object
			updateData = jQuery.parseJSON(jsonString);
		}
		catch (error) {
			alert("recieveUpdateData failed. " + "<br>Error name: " + error.name + "<br>Error Message: " + error.message);
			return;
		}

		//alert("recieveUpdateData passed trycatch block."); //debug hook

		if (!updateData.hasOwnProperty('data')) {
			if (_data && _data.hasOwnProperty('data')) {
				updateData['data'] = _data['data'];
			}
			else {
				updateData['data'] = {};
			}
		}

		if (_isInitialised) // all templates have been registered, so render them
		{
			doUpdate(updateData);
		}
		else {
			_data = updateData; // all templates have not been registered. We set _data directly here which will be applied after the template is loaded with the initial data
		}
	};

	/**
	 * This function does the update by calling the methods on the current state.
	 * @param {Object} data - The data to be used in the update.
	 */
	var doUpdate = function (data) {
		if (_currentState == null) {
			return;
		}

		data = _currentState.onBeforeUpdate(data);

		if (data === false) {
			alert('data is false, return');
			return; // A beforeUpdateCallback returned a false value, this prevents the render from occuring
		}

		_data = data;

		_currentState.onUpdate(_data);

		_currentState.onAfterUpdate(_data);
	};

	/**
	 * Execute all callbacks in the callbacks array/object provided, updateData is passed to them for processing and potential modification.
	 * @param {Object.<string, Function>} callbacks - The callbacks to be executed.
	 * @param {Object} data - The data to be passed to the callbacks.
	 * @returns {Object} The potentially modified data.
	 */
	var executeCallbacks = function (callbacks, data) {
		for (var key in callbacks) {
			if (callbacks.hasOwnProperty(key) && jQuery.isFunction(callbacks[key])) {
				data = callbacks[key].call(this, data);
			}
		}

		return data;
	};

	return {
		/**
		 * Initializes the NanoStateManager.
		 */
		init: function () {
			init();
		},
		/**
		 * Receives update data from the server.
		 * @param {string} jsonString - The JSON string received from the server.
		 */
		receiveUpdateData: function (jsonString) {
			receiveUpdateData(jsonString);
		},
		/**
		 * Adds a callback to be executed before the update.
		 * @param {string} key - The key of the callback.
		 * @param {Function} callbackFunction - The callback function.
		 */
		addBeforeUpdateCallback: function (key, callbackFunction) {
			_beforeUpdateCallbacks[key] = callbackFunction;
		},
		/**
		 * Adds multiple callbacks to be executed before the update.
		 * @param {Object.<string, Function>} callbacks - The callbacks to be added.
		 */
		addBeforeUpdateCallbacks: function (callbacks) {
			for (var callbackKey in callbacks) {
				if (!callbacks.hasOwnProperty(callbackKey)) {
					continue;
				}
				NanoStateManager.addBeforeUpdateCallback(callbackKey, callbacks[callbackKey]);
			}
		},
		/**
		 * Removes a callback to be executed before the update.
		 * @param {string} key - The key of the callback.
		 */
		removeBeforeUpdateCallback: function (key) {
			if (_beforeUpdateCallbacks.hasOwnProperty(key)) {
				delete _beforeUpdateCallbacks[key];
			}
		},
		/**
		 * Executes all callbacks to be executed before the update.
		 * @param {Object} data - The data to be passed to the callbacks.
		 * @returns {Object} The potentially modified data.
		 */
		executeBeforeUpdateCallbacks: function (data) {
			return executeCallbacks(_beforeUpdateCallbacks, data);
		},
		/**
		 * Adds a callback to be executed after the update.
		 * @param {string} key - The key of the callback.
		 * @param {Function} callbackFunction - The callback function.
		 */
		addAfterUpdateCallback: function (key, callbackFunction) {
			_afterUpdateCallbacks[key] = callbackFunction;
		},
		/**
		 * Adds multiple callbacks to be executed after the update.
		 * @param {Object.<string, Function>} callbacks - The callbacks to be added.
		 */
		addAfterUpdateCallbacks: function (callbacks) {
			for (var callbackKey in callbacks) {
				if (!callbacks.hasOwnProperty(callbackKey)) {
					continue;
				}
				NanoStateManager.addAfterUpdateCallback(callbackKey, callbacks[callbackKey]);
			}
		},
		/**
		 * Removes a callback to be executed after the update.
		 * @param {string} key - The key of the callback.
		 */
		removeAfterUpdateCallback: function (key) {
			if (_afterUpdateCallbacks.hasOwnProperty(key)) {
				delete _afterUpdateCallbacks[key];
			}
		},
		/**
		 * Executes all callbacks to be executed after the update.
		 * @param {Object} data - The data to be passed to the callbacks.
		 * @returns {Object} The potentially modified data.
		 */
		executeAfterUpdateCallbacks: function (data) {
			return executeCallbacks(_afterUpdateCallbacks, data);
		},
		/**
		 * Adds a state to the NanoStateManager.
		 * @param {NanoStateClass} state - The state to be added.
		 */
		addState: function (state) {
			if (!(state instanceof NanoStateClass)) {
				alert('ERROR: Attempted to add a state which is not instanceof NanoStateClass');
				return;
			}
			if (!state.key) {
				alert('ERROR: Attempted to add a state with an invalid stateKey');
				return;
			}
			_states[state.key] = state;
		},
		/**
		 * Sets the current state of the NanoStateManager.
		 * @param {string} stateKey - The key of the state.
		 * @returns {boolean} True if the state was successfully set, false otherwise.
		 */
		setCurrentState: function (stateKey) {
			if (typeof stateKey == 'undefined' || !stateKey) {
				alert('ERROR: No state key was passed!');
				return false;
			}
			if (!_states.hasOwnProperty(stateKey)) {
				alert('ERROR: Attempted to set a current state which does not exist: ' + stateKey);
				return false;
			}

			var previousState = _currentState;

			_currentState = _states[stateKey];

			if (previousState != null) {
				previousState.onRemove(_currentState);
			}

			_currentState.onAdd(previousState);

			return true;
		},
		/**
		 * Gets the current state of the NanoStateManager.
		 * @returns {NanoStateClass} The current state.
		 */
		getCurrentState: function () {
			return _currentState;
		}
	};
}();
