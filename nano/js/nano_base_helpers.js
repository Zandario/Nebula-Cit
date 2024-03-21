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
