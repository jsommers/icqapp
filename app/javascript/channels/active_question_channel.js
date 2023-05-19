import consumer from "channels/consumer"

consumer.subscriptions.create("ActiveQuestionChannel", {
  connected() {
    // Called when the subscription is ready for use on the server
  },

  disconnected() {
    // Called when the subscription has been terminated by the server
  },

  received(data) {
    // Called when there's incoming data on the websocket for this channel
  },

  enable: function() {
    return this.perform('enable');
  },

  disable: function() {
    return this.perform('disable');
  }
});
