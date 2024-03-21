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
