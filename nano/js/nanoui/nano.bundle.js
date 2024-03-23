/**
 * NanoUtility is the place to store utility functions.
 * @returns {Object} An object with utility methods.
 */
var NanoUtility = function () {
	/**
	 * This is populated with the base url parameters (used by all links), which is probably just the "src" parameter.
	 * @type {Object}
	 */
	var _urlParameters = {};

	return {
		/**
		 * Initializes the utility by storing data in the body tag.
		 */
		init: function () {
			var body = $('body'); // We store data in the body tag, it's as good a place as any

			_urlParameters = body.data('urlParameters');
		},
		/**
		 * Generates a Byond href, combines _urlParameters with parameters.
		 * @param {Object} parameters - The parameters to be combined with _urlParameters.
		 * @returns {string} The generated href.
		 */
		generateHref: function (parameters) {
			var queryString = '?';

			for (var key in _urlParameters) {
				if (_urlParameters.hasOwnProperty(key)) {
					if (queryString !== '?') {
						queryString += ';';
					}
					queryString += key + '=' + _urlParameters[key];
				}
			}

			for (var key in parameters) {
				if (parameters.hasOwnProperty(key)) {
					if (queryString !== '?') {
						queryString += ';';
					}
					queryString += key + '=' + parameters[key];
				}
			}
			return queryString;
		}
	}
}();

if (typeof jQuery == 'undefined') {
	alert('ERROR: Javascript library failed to load!');
}
if (typeof doT == 'undefined') {
	alert('ERROR: Template engine failed to load!');
}

(function () {
	var _alert = window.alert;
	window.alert = function (str) {
		window.location = "byond://?nano_err=" + encodeURIComponent(str);
		_alert(str);
	};
})();

/**
 * All scripts are initialised here, this allows control of init order.
 */
$(document).ready(function () {
	NanoUtility.init();
	NanoStateManager.init();
	NanoTemplate.init();
});

if (!Array.prototype.indexOf) {
	Array.prototype.indexOf = function (elt /*, from*/) {
		var len = this.length;

		var from = Number(arguments[1]) || 0;
		from = (from < 0)
			? Math.ceil(from)
			: Math.floor(from);
		if (from < 0)
			from += len;

		for (; from < len; from++) {
			if (from in this &&
				this[from] === elt)
				return from;
		}
		return -1;
	};
};

if (!String.prototype.format) {
	String.prototype.format = function (args) {
		var str = this;
		return str.replace(String.prototype.format.regex, function (item) {
			var intVal = parseInt(item.substring(1, item.length - 1));
			var replace;
			if (intVal >= 0) {
				replace = args[intVal];
			} else if (intVal === -1) {
				replace = "{";
			} else if (intVal === -2) {
				replace = "}";
			} else {
				replace = "";
			}
			return replace;
		});
	};
	String.prototype.format.regex = new RegExp("{-?[0-9]+}", "g");
};

/**
 * Adds a size method to the Object prototype that returns the number of properties in the object.
 * @returns {number} The number of properties in the object.
 */
Object.size = function (obj) {
	var size = 0, key;
	for (var key in obj) {
		if (obj.hasOwnProperty(key)) size++;
	}
	return size;
};

if (!window.console) {
	window.console = {
		log: function (str) {
			return false;
		}
	};
};

/**
 * Adds a toTitleCase method to the String prototype that converts the string to title case.
 * @returns {string} The string converted to title case.
 */
String.prototype.toTitleCase = function () {
	var smallWords = /^(a|an|and|as|at|but|by|en|for|if|in|of|on|or|the|to|vs?\.?|via)$/i;

	return this.replace(/([^\W_]+[^\s-]*) */g, function (match, p1, index, title) {
		if (index > 0 && index + p1.length !== title.length &&
			p1.search(smallWords) > -1 && title.charAt(index - 2) !== ":" &&
			title.charAt(index - 1).search(/[^\s-]/) < 0) {
			return match.toLowerCase();
		}

		if (p1.substr(1).search(/[A-Z]|\../) > -1) {
			return match;
		}

		return match.charAt(0).toUpperCase() + match.substr(1);
	});
};

$.ajaxSetup({
	cache: false
});

/**
 * Adds an inheritsFrom method to the Function prototype that sets up inheritance from a parent class or object.
 * @param {Object|Function} parentClassOrObject - The parent class or object to inherit from.
 * @returns {Function} The function with inheritance set up.
 */
Function.prototype.inheritsFrom = function (parentClassOrObject) {
	this.prototype = new parentClassOrObject;
	this.prototype.constructor = this;
	this.prototype.parent = parentClassOrObject.prototype;
	return this;
};

if (!String.prototype.trim) {
	String.prototype.trim = function () {
		return this.replace(/^\s+|\s+$/g, '');
	};
}

/**
 * Adds a ckey method to the String prototype that replicates the ckey proc from BYOND.
 * @returns {string} The string with all non-alphanumeric characters removed and converted to lower case.
 */
if (!String.prototype.ckey) {
	String.prototype.ckey = function () {
		return this.replace(/\W/g, '').toLowerCase();
	};
}
/**
 * NanoTemplate is a self-invoking function that manages templates.
 * @returns {Object} An object with methods to manage templates.
 */
var NanoTemplate = function () {

	/**
	 * An object that stores template data.
	 * @type {Object}
	 */
	var _templateData = {};

	/**
	 * A string that stores the template file name.
	 * @type {string}
	 */
	var _templateFileName = '';


	/**
	 * An object that stores templates.
	 * @type {Object}
	 */
	var _templates = {};

	/**
	 * An object that stores compiled templates.
	 * @type {Object}
	 */
	var _compiledTemplates = {};


	/**
	 * An object that stores helper functions.
	 * @type {Object}
	 */
	var _helpers = {};

	/**
	 * Initializes the NanoTemplate by loading all templates.
	 */
	var init = function () {
		// We store templateData in the body tag, it's as good a place as any
		_templateData = $('body').data('templateData');
		_templateFileName = $('body').data('initialData')['config']['templateFileName'];

		if (_templateData == null) {
			alert('Error: Template data did not load correctly.');
		}

		loadAllTemplates();
	};

	/**
	 * Loads all templates from the template file.
	 */
	var loadAllTemplates = function () {
		$.when($.ajax({
			url: _templateFileName,
			cache: false,
			dataType: 'json'
		}))
			.done(function (allTemplates) {

				for (var key in _templateData) {
					var templateMarkup = allTemplates[_templateData[key]];
					templateMarkup += '<div class="clearBoth"></div>';

					try {
						NanoTemplate.addTemplate(key, templateMarkup);
					}
					catch (error) {
						alert('ERROR: Loading template ' + key + '(' + _templateData[key] + ') failed with error: ' + error.message);
						return;
					}
					delete _templateData[key];
				}
				$(document).trigger('templatesLoaded');
			})
			.fail(function () {
				alert('ERROR: Failed to locate or parse templates file.');
			});
	};

	/**
	 * Compiles all templates stored in _templates.
	 */
	var compileTemplates = function () {

		for (var key in _templates) {
			try {
				_compiledTemplates[key] = doT.template(_templates[key], null, _templates)
			}
			catch (error) {
				alert('ERROR: Compiling template key "' + key + '" ("' + _templateData[key] + '") failed with error: ' + error);
			}
		}
	};

	return {
		/**
		 * Initializes the NanoTemplate.
		 */
		init: function () {
			init();
		},

		/**
		 * Adds a template to _templates.
		 * @param {string} key - The key of the template.
		 * @param {string} templateString - The string representation of the template.
		 */
		addTemplate: function (key, templateString) {
			_templates[key] = templateString;
		},

		/**
		 * Checks if a template exists in _templates.
		 * @param {string} key - The key of the template.
		 * @returns {boolean} True if the template exists, false otherwise.
		 */
		templateExists: function (key) {
			return _templates.hasOwnProperty(key);
		},

		/**
		 * Parses a template with the provided data.
		 * @param {string} templateKey - The key of the template.
		 * @param {Object} data - The data to be used in the template.
		 * @returns {string} The parsed template.
		 */
		parse: function (templateKey, data) {
			if (!_compiledTemplates.hasOwnProperty(templateKey) || !_compiledTemplates[templateKey]) {
				if (!_templates.hasOwnProperty(templateKey)) {
					alert('ERROR: Template "' + templateKey + '" does not exist in _compiledTemplates!');
					return '<h2>Template error (does not exist)</h2>';
				}
				compileTemplates();
			}
			if (typeof _compiledTemplates[templateKey] != 'function') {
				return '<h2>Template error (failed to compile)</h2>';
			}
			return _compiledTemplates[templateKey].call(this, data['data'], data['config'], _helpers);
		},

		/**
		 * Adds a helper function to _helpers.
		 * @param {string} helperName - The name of the helper function.
		 * @param {Function} helperFunction - The helper function.
		 */
		addHelper: function (helperName, helperFunction) {
			if (!jQuery.isFunction(helperFunction)) {
				alert('NanoTemplate.addHelper failed to add ' + helperName + ' as it is not a function.');
				return;
			}

			_helpers[helperName] = helperFunction;
		},

		/**
		 * Adds multiple helper functions to _helpers.
		 * @param {Object} helpers - An object with helper functions.
		 */
		addHelpers: function (helpers) {
			for (var helperName in helpers) {
				if (!helpers.hasOwnProperty(helperName)) {
					continue;
				}
				NanoTemplate.addHelper(helperName, helpers[helperName]);
			}
		},

		/**
		 * Removes a helper function from _helpers.
		 * @param {string} helperName - The name of the helper function.
		 */
		removeHelper: function (helperName) {
			if (helpers.hasOwnProperty(helperName)) {
				delete _helpers[helperName];
			}
		}
	}
}();
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
/**
 * NanoStateClass is the base state class, it is not to be used directly.
 * @constructor
 */
function NanoStateClass() {
	/*
	if (typeof this.key != 'string' || !this.key.length) {
		alert('ERROR: Tried to create a state with an invalid state key: ' + this.key);
		return;
	}

	this.key = this.key.toLowerCase();

	NanoStateManager.addState(this);
	*/
}

/**
 * The key of the state.
 * @type {string}
 */
NanoStateClass.prototype.key = null;

/**
 * Indicates if the layout has been rendered.
 * @type {boolean}
 */
NanoStateClass.prototype.layoutRendered = false;

/**
 * Indicates if the content has been rendered.
 * @type {boolean}
 */
NanoStateClass.prototype.contentRendered = false;

/**
 * Indicates if the map has been initialised.
 * @type {boolean}
 */
NanoStateClass.prototype.mapInitialised = false;


/**
 * Checks if the current state is this state.
 * @returns {boolean} True if the current state is this state, false otherwise.
 */
NanoStateClass.prototype.isCurrent = function () {
	return NanoStateManager.getCurrentState() == this;
};

/**
 * Adds the state and sets up the base callbacks and helpers.
 * @param {NanoStateClass} previousState - The previous state.
 */
NanoStateClass.prototype.onAdd = function (previousState) {
	// Do not add code here, add it to the 'default' state (nano_state_defaut.js) or create a new state and override this function

	NanoBaseCallbacks.addCallbacks();
	NanoBaseHelpers.addHelpers();
};

/**
 * Removes the state and removes the base callbacks and helpers.
 * @param {NanoStateClass} nextState - The next state.
 */
NanoStateClass.prototype.onRemove = function (nextState) {
	// Do not add code here, add it to the 'default' state (nano_state_defaut.js) or create a new state and override this function

	NanoBaseCallbacks.removeCallbacks();
	NanoBaseHelpers.removeHelpers();
};

/**
 * Executes before the state is updated.
 * @param {Object} data - The data to be used in the update.
 * @returns {Object|boolean} The data to continue, false to prevent onUpdate and onAfterUpdate.
 */
NanoStateClass.prototype.onBeforeUpdate = function (data) {
	// Do not add code here, add it to the 'default' state (nano_state_defaut.js) or create a new state and override this function

	data = NanoStateManager.executeBeforeUpdateCallbacks(data);

	return data; // Return data to continue, return false to prevent onUpdate and onAfterUpdate
};

/**
 * Updates the state.
 * @param {Object} data - The data to be used in the update.
 */
NanoStateClass.prototype.onUpdate = function (data) {
	// Do not add code here, add it to the 'default' state (nano_state_defaut.js) or create a new state and override this function

	try {
		if (!this.layoutRendered || (data['config'].hasOwnProperty('autoUpdateLayout') && data['config']['autoUpdateLayout'])) {
			$("#uiLayout").html(NanoTemplate.parse('layout', data)); // render the 'mail' template to the #mainTemplate div
			this.layoutRendered = true;
		}
		if (!this.contentRendered || (data['config'].hasOwnProperty('autoUpdateContent') && data['config']['autoUpdateContent'])) {
			$("#uiContent").html(NanoTemplate.parse('main', data)); // render the 'mail' template to the #mainTemplate div

			if (NanoTemplate.templateExists('layoutHeader')) {
				$("#uiHeaderContent").html(NanoTemplate.parse('layoutHeader', data));
			}
			this.contentRendered = true;
		}
		if (NanoTemplate.templateExists('mapContent')) {
			if (!this.mapInitialised) {
				// Add drag functionality to the map ui
				$('#uiMap').draggable();

				$('#uiMapTooltip')
					.off('click')
					.on('click', function (event) {
						event.preventDefault();
						$(this).fadeOut(400);
					});

				this.mapInitialised = true;
			}

			$("#uiMapContent").html(NanoTemplate.parse('mapContent', data)); // render the 'mapContent' template to the #uiMapContent div

			if (data['config'].hasOwnProperty('showMap') && data['config']['showMap']) {
				$('#uiContent').addClass('hidden');
				$('#uiMapWrapper').removeClass('hidden');
			}
			else {
				$('#uiMapWrapper').addClass('hidden');
				$('#uiContent').removeClass('hidden');
			}
		}
		if (NanoTemplate.templateExists('mapHeader')) {
			$("#uiMapHeader").html(NanoTemplate.parse('mapHeader', data)); // render the 'mapHeader' template to the #uiMapHeader div
		}
		if (NanoTemplate.templateExists('mapFooter')) {
			$("#uiMapFooter").html(NanoTemplate.parse('mapFooter', data)); // render the 'mapFooter' template to the #uiMapFooter div
		}
	}
	catch (error) {
		alert('ERROR: An error occurred while rendering the UI: ' + error.message);
		return;
	}
};

/**
 * Executes after the state is updated.
 * @param {Object} data - The data to be used in the update.
 */
NanoStateClass.prototype.onAfterUpdate = function (data) {
	// Do not add code here, add it to the 'default' state (nano_state_defaut.js) or create a new state and override this function

	NanoStateManager.executeAfterUpdateCallbacks(data);
};

/**
 * Alerts the provided text.
 * @param {string} text - The text to be alerted.
 */
NanoStateClass.prototype.alertText = function (text) {
	// Do not add code here, add it to the 'default' state (nano_state_defaut.js) or create a new state and override this function

	alert(text);
};
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
/**
 * NanoBaseCallbacks is a self-invoking function that manages callbacks for updates.
 */
NanoBaseCallbacks = function () {
	/**
	 * Used to disable clicks for a short period after each click (to avoid mis-clicks)
	 * @type {boolean}
	 */
	var _canClick = true;

	/**
	 * An object that stores callbacks to be executed before an update.
	 * @type {Object}
	 */
	var _baseBeforeUpdateCallbacks = {}

	/**
	 * An object that stores callbacks to be executed after an update.
	 * @type {Object}
	 */
	var _baseAfterUpdateCallbacks = {
		/**
		 * This callback is triggered after new data is processed.
		 * It updates the status/visibility icon and adds click event handling to buttons/links.
		 * @param {Object} updateData - The data received from the update.
		 *
		 * @returns {Object} The same updateData object that was passed in.
		 */
		status: function (updateData) {
			var uiStatusClass;
			if (updateData['config']['status'] == 2) {
				uiStatusClass = 'icon24 uiStatusGood';
				$('.linkActive').removeClass('inactive');
			}
			else if (updateData['config']['status'] == 1) {
				uiStatusClass = 'icon24 uiStatusAverage';
				$('.linkActive').addClass('inactive');
			}
			else {
				uiStatusClass = 'icon24 uiStatusBad'
				$('.linkActive').addClass('inactive');
			}
			$('#uiStatusIcon').attr('class', uiStatusClass);

			$('.linkActive').stopTime('linkPending');
			$('.linkActive').removeClass('linkPending');

			$('.linkActive')
				.off('click')
				.on('click', function (event) {
					event.preventDefault();
					var href = $(this).data('href');
					if (href != null && _canClick) {
						_canClick = false;
						$('body').oneTime(300, 'enableClick', function () {
							_canClick = true;
						});
						if (updateData['config']['status'] == 2) {
							$(this).oneTime(300, 'linkPending', function () {
								$(this).addClass('linkPending');
							});
						}
						window.location.href = href;
					}
				});

			return updateData;
		},
		/**
		 * This callback is triggered after new data is processed.
		 * It updates map icons and adds event handling to the zoom link.
		 * @param {Object} updateData - The data received from the update.
		 *
		 * @returns {Object} The same updateData object that was passed in.
		 */
		nanomap: function (updateData) {
			$('.mapIcon')
				.off('mouseenter mouseleave')
				.on('mouseenter',
					function (event) {
						var self = this;
						$('#uiMapTooltip')
							.html($(this).children('.tooltip').html())
							.show()
							.stopTime()
							.oneTime(5000, 'hideTooltip', function () {
								$(this).fadeOut(500);
							});
					}
				);

			$('.zoomLink')
				.off('click')
				.on('click', function (event) {
					event.preventDefault();
					var zoomLevel = $(this).data('zoomLevel');
					var uiMapObject = $('#uiMap');
					var uiMapWidth = uiMapObject.width() * zoomLevel;
					var uiMapHeight = uiMapObject.height() * zoomLevel;

					uiMapObject.css({
						zoom: zoomLevel,
						left: '50%',
						top: '50%',
						marginLeft: '-' + Math.floor(uiMapWidth / 2) + 'px',
						marginTop: '-' + Math.floor(uiMapHeight / 2) + 'px'
					});
				});

			$('#uiMapImage').attr('src', updateData['config']['mapName'] + '-' + updateData['config']['mapZLevel'] + '.png');

			return updateData;
		}
	};

	return {
		/**
		 * Adds the callbacks stored in _baseBeforeUpdateCallbacks and _baseAfterUpdateCallbacks to the NanoStateManager.
		 */
		addCallbacks: function () {
			NanoStateManager.addBeforeUpdateCallbacks(_baseBeforeUpdateCallbacks);
			NanoStateManager.addAfterUpdateCallbacks(_baseAfterUpdateCallbacks);
		},
		/**
		 * Removes the callbacks stored in _baseBeforeUpdateCallbacks and _baseAfterUpdateCallbacks from the NanoStateManager.
		 */
		removeCallbacks: function () {
			for (var callbackKey in _baseBeforeUpdateCallbacks) {
				if (_baseBeforeUpdateCallbacks.hasOwnProperty(callbackKey)) {
					NanoStateManager.removeBeforeUpdateCallback(callbackKey);
				}
			}
			for (var callbackKey in _baseAfterUpdateCallbacks) {
				if (_baseAfterUpdateCallbacks.hasOwnProperty(callbackKey)) {
					NanoStateManager.removeAfterUpdateCallback(callbackKey);
				}
			}
		}
	};
}();
/**
 * NanoBaseHelpers is where the base template helpers (common to all templates) are stored.
 * @namespace NanoBaseHelpers
 */
NanoBaseHelpers = function () {
	var _baseHelpers = {
		/**
		 * Changes UI styling to "syndicate mode".
		 */
		syndicateMode: function () {
			$('body').css("background-color", "#330404");
			$('body').css("background-image", "url('uiBackground-Syndicate.png')");
			$('body').css("background-position", "50% 0");
			$('body').css("background-repeat", "repeat");
			$('body').css("color", "#ff0000");

			$('hr').css("background-color", "#551414");
			$('a').css("background", "#551414");
			$('a:link').css("background", "#551414");
			$('a:visited').css("background", "#551414");
			$('a:active').css("background", "#551414");
			$('linkOn').css("background", "#551414");
			$('linkOff').css("background", "#551414");
			$('input').css("background", "#551414");
			$('a:hover').css("color", "#551414");
			$('a.white').css("color", "#551414");
			$('a.white:link').css("color", "#551414");
			$('a.white:visited').css("color", "#551414");
			$('a.white:active').css("color", "#551414");
			$('a.white:hover').css("background", "#551414");
			$('linkOn').css("background", "#771414");
			$('a.linkOn:link').css("background", "#771414");
			$('a.linkOn:visited').css("background", "#771414");
			$('a.linkOn:active').css("background", "#771414");
			$('a.linkOn:hover').css("background", "#771414");
			$('statusDisplay').css("border", "1px solid #551414");
			$('block').css("border", "1px solid #551414");
			$('progressFill').css("background", "#551414");
			$('statusDisplay').css("border", "1px solid #551414");

			$('itemLabelNarrow').css("color", "#ff0000");
			$('itemLabel').css("color", "#ff0000");
			$('itemLabelWide').css("color", "#ff0000");
			$('itemLabelWider').css("color", "#ff0000");
			$('itemLabelWidest').css("color", "#ff0000");

			$('link').css("border", "1px solid #ff0000");
			$('linkOn').css("border", "1px solid #ff0000");
			$('linkOff').css("border", "1px solid #ff0000");
			$('selected').css("border", "1px solid #ff0000");
			$('disabled').css("border", "1px solid #ff0000");
			$('yellowButton').css("border", "1px solid #ff0000");
			$('redButton').css("border", "1px solid #ff0000");

			$('link').css("background", "#330000");
			$('linkOn').css("background", "#330000");
			$('linkOff').css("background", "#330000");
			$('selected').css("background", "#330000");
			$('disabled').css("background", "#330000");
			$('yellowButton').css("background", "#330000");
			$('redButton').css("background", "#330000");

			$('.average').css("color", "#ff0000");

			$('#uiTitleFluff').css("background-image", "url('uiTitleFluff-Syndicate.png')");
			$('#uiTitleFluff').css("background-position", "50% 50%");
			$('#uiTitleFluff').css("background-repeat", "no-repeat");

			return '';
		},
		/**
		 * Generates a Byond link.
		 * @param {string} text - The text of the link.
		 * @param {string} icon - The icon of the link.
		 * @param {object} parameters - The parameters of the link.
		 * @param {string} status - The status of the link.
		 * @param {string} elementClass - The class of the link element.
		 * @param {string} elementId - The id of the link element.
		 *
		 * @returns {string} The generated link.
		 */
		link: function (text, icon, parameters, status, elementClass, elementId) {

			var iconHtml = '';
			var iconClass = 'noIcon';
			if (typeof icon != 'undefined' && icon) {
				iconHtml = '<div class="uiLinkPendingIcon"></div><div class="uiIcon16 icon-' + icon + '"></div>';
				iconClass = text ? 'hasIcon' : 'onlyIcon';
			}

			if (typeof elementClass == 'undefined' || !elementClass) {
				elementClass = 'link';
			}

			var elementIdHtml = '';
			if (typeof elementId != 'undefined' && elementId) {
				elementIdHtml = 'id="' + elementId + '"';
			}

			if (typeof status != 'undefined' && status) {
				return '<div unselectable="on" class="link ' + iconClass + ' ' + elementClass + ' ' + status + '" ' + elementIdHtml + '>' + iconHtml + text + '</div>';
			}

			return '<div unselectable="on" class="linkActive ' + iconClass + ' ' + elementClass + '" data-href="' + NanoUtility.generateHref(parameters) + '" ' + elementIdHtml + '>' + iconHtml + text + '</div>';
		},
		/**
		 * Rounds a number to the nearest integer.
		 * @param {number} number - The number to round.
		 *
		 * @returns {number} The rounded number.
		 */
		round: function (number) {
			return Math.round(number);
		},
		/**
		 * Returns the number fixed to 1 decimal.
		 * @param {number} number - The number to fix.
		 *
		 * @returns {number} The fixed number.
		 */
		fixed: function (number) {
			return Math.round(number * 10) / 10;
		},
		/**
		 * Rounds a number down to integer.
		 * @param {number} number - The number to floor.
		 *
		 * @returns {number} The floored number.
		 */
		floor: function (number) {
			return Math.floor(number);
		},
		/**
		 * Rounds a number up to integer.
		 * @param {number} number - The number to round up.
		 *
		 * @returns {number} The rounded up number.
		 */
		ceil: function (number) {
			return Math.ceil(number);
		},
		// Format a string (~string("Hello {0}, how are {1}?", 'Martin', 'you') becomes "Hello Martin, how are you?")
		/**
		 * Formats a string.
		 * @example (~string("Hello {0}, how are {1}?", 'Martin', 'you') becomes "Hello Martin, how are you?")
		 * @param {number} number - The number to round up.
		 *
		 * @returns {number} The rounded up number.
		 */
		string: function () {
			if (arguments.length == 0) {
				return '';
			}
			else if (arguments.length == 1) {
				return arguments[0];
			}
			else if (arguments.length > 1) {
				stringArgs = [];
				for (var i = 1; i < arguments.length; i++) {
					stringArgs.push(arguments[i]);
				}
				return arguments[0].format(stringArgs);
			}
			return '';
		},
		formatNumber: function (x) {
			// From http://stackoverflow.com/questions/2901102/how-to-print-a-number-with-commas-as-thousands-separators-in-javascript
			var parts = x.toString().split(".");
			parts[0] = parts[0].replace(/\B(?=(\d{3})+(?!\d))/g, ",");
			return parts.join(".");
		},
		// Capitalize the first letter of a string. From http://stackoverflow.com/questions/1026069/capitalize-the-first-letter-of-string-in-javascript
		capitalizeFirstLetter: function (string) {
			return string.charAt(0).toUpperCase() + string.slice(1);
		},
		/**
		 * Displays a bar. Used to show health, capacity, etc.
		 * Use difClass if the entire display bar class should be different
		 * @param {number} value - The current value.
		 * @param {number} rangeMin - The minimum value.
		 * @param {number} rangeMax - The maximum value.
		 * @param {string} styleClass - The class of the bar.
		 * @param {string} showText - The text to show on the bar.
		 * @param {string} difClass - The class of the entire display bar.
		 * @param {string} direction - The direction of the bar.
		 * @param {string} id - The id of the bar.
		 *
		 * @returns {string} The generated bar.
		 */
		displayBar: function (value, rangeMin, rangeMax, styleClass, showText, difClass, direction, id) {

			if (rangeMin < rangeMax) {
				if (value < rangeMin) {
					value = rangeMin;
				}
				else if (value > rangeMax) {
					value = rangeMax;
				}
			}
			else {
				if (value > rangeMin) {
					value = rangeMin;
				}
				else if (value < rangeMax) {
					value = rangeMax;
				}
			}

			if (typeof styleClass == 'undefined' || !styleClass) {
				styleClass = '';
			}

			if (typeof showText == 'undefined' || !showText) {
				showText = '';
			}

			if (typeof difClass == 'undefined' || !difClass) {
				difClass = ''
			}

			if (typeof direction == 'undefined' || !direction) {
				direction = 'width'
			}
			else {
				direction = 'height'
			}

			var percentage = Math.round((value - rangeMin) / (rangeMax - rangeMin) * 100);

			return '<div id="displayBar' + id + '" class="displayBar' + difClass + ' ' + styleClass + '"><div id="displayBar' + id + 'Fill" class="displayBar' + difClass + 'Fill ' + styleClass + '" style="' + direction + ': ' + percentage + '%;"></div><div id="displayBar' + id + 'Text" class="displayBar' + difClass + 'Text ' + styleClass + '">' + showText + '</div></div>';
		},
		/**
		 * This function generates HTML for displaying DNA blocks.
		 *
		 * @param {string} dnaString - The DNA sequence to be displayed.
		 * @param {number} selectedBlock - The currently selected block.
		 * @param {number} selectedSubblock - The currently selected subblock within the selected block.
		 * @param {number} blockSize - The size of each block.
		 * @param {string} paramKey - The key used to determine the parameters for the block and subblock.
		 *
		 * @returns {string} The generated HTML for displaying the DNA blocks.
		 */
		displayDNABlocks: function (dnaString, selectedBlock, selectedSubblock, blockSize, paramKey) {
			if (!dnaString) {
				return '<div class="notice">Please place a valid subject into the DNA modifier.</div>';
			}

			var characters = dnaString.split('');

			var html = '<div class="dnaBlock"><div class="link dnaBlockNumber">1</div>';
			var block = 1;
			var subblock = 1;
			for (index in characters) {
				if (!characters.hasOwnProperty(index) || typeof characters[index] === 'object') {
					continue;
				}

				var parameters;
				if (paramKey.toUpperCase() == 'UI') {
					parameters = { 'selectUIBlock': block, 'selectUISubblock': subblock };
				}
				else {
					parameters = { 'selectSEBlock': block, 'selectSESubblock': subblock };
				}

				var status = 'linkActive';
				if (block == selectedBlock && subblock == selectedSubblock) {
					status = 'selected';
				}

				html += '<div class="link ' + status + ' dnaSubBlock" data-href="' + NanoUtility.generateHref(parameters) + '" id="dnaBlock' + index + '">' + characters[index] + '</div>'

				index++;
				if (index % blockSize == 0 && index < characters.length) {
					block++;
					subblock = 1;
					html += '</div><div class="dnaBlock"><div class="link dnaBlockNumber">' + block + '</div>';
				}
				else {
					subblock++;
				}
			}

			html += '</div>';

			return html;
		},
		/**
		 * Returns the current time of day in deciseconds since midnight.
		 *
		 * @returns {number} The current time of day.
		 */
		byondTimeOfDay: function _byondTimeOfDay() {
			if (typeof _byondTimeOfDay.midnight == 'undefined') {
				_byondTimeOfDay.midnight = new Date().setUTCHours(0, 0, 0, 0);
			}
			return (new Date() - _byondTimeOfDay.midnight) / 100; // deciseconds since midnight
		}
	};

	return {
		/**
		 * Adds the base helpers to the NanoTemplate.
		 */
		addHelpers: function () {
			NanoTemplate.addHelpers(_baseHelpers);
		},
		/**
		 * Removes the base helpers from the NanoTemplate.
		 */
		removeHelpers: function () {
			for (var helperKey in _baseHelpers) {
				if (_baseHelpers.hasOwnProperty(helperKey)) {
					NanoTemplate.removeHelper(helperKey);
				}
			}
		}
	};
}();
