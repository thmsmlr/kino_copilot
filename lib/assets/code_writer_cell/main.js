import * as Vue from "https://cdn.jsdelivr.net/npm/vue@3.2.26/dist/vue.esm-browser.prod.js";

export function init(ctx, payload) {
  ctx.importCSS("main.css");
  ctx.importCSS("https://fonts.googleapis.com/css2?family=Inter:wght@400;500&display=swap");

  const app = Vue.createApp({
    components: {},

    template: `
    <div class="bg-blue-50 border border-gray-200 px-2 py-3 rounded-bl rounded-br"
         style="font-family: Inter">

      <div class="rounded-md bg-red-50 border border-red-300 p-4" v-if="payload.errors">
        <div class="flex">
          <div class="flex-shrink-0">
            <svg class="h-5 w-5 text-red-400" viewBox="0 0 20 20" fill="currentColor" aria-hidden="true">
              <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.28 7.22a.75.75 0 00-1.06 1.06L8.94 10l-1.72 1.72a.75.75 0 101.06 1.06L10 11.06l1.72 1.72a.75.75 0 101.06-1.06L11.06 10l1.72-1.72a.75.75 0 00-1.06-1.06L10 8.94 8.28 7.22z" clip-rule="evenodd" />
            </svg>
          </div>
          <div class="ml-3">
            <pre class="text-sm font-medium text-red-800">{{ payload.errors[0] }}</pre>
          </div>
        </div>
      </div>

      <div class="flex items-center gap-3" v-else>
        <svg class="ml-1 w-5 h-5 text-gray-600" xmlns="http://www.w3.org/2000/svg" fill="currentColor" viewBox="0 0 24 24" role="img">
          <path d="M22.2819 9.8211a5.9847 5.9847 0 0 0-.5157-4.9108 6.0462 6.0462 0 0 0-6.5098-2.9A6.0651 6.0651 0 0 0 4.9807 4.1818a5.9847 5.9847 0 0 0-3.9977 2.9 6.0462 6.0462 0 0 0 .7427 7.0966 5.98 5.98 0 0 0 .511 4.9107 6.051 6.051 0 0 0 6.5146 2.9001A5.9847 5.9847 0 0 0 13.2599 24a6.0557 6.0557 0 0 0 5.7718-4.2058 5.9894 5.9894 0 0 0 3.9977-2.9001 6.0557 6.0557 0 0 0-.7475-7.0729zm-9.022 12.6081a4.4755 4.4755 0 0 1-2.8764-1.0408l.1419-.0804 4.7783-2.7582a.7948.7948 0 0 0 .3927-.6813v-6.7369l2.02 1.1686a.071.071 0 0 1 .038.052v5.5826a4.504 4.504 0 0 1-4.4945 4.4944zm-9.6607-4.1254a4.4708 4.4708 0 0 1-.5346-3.0137l.142.0852 4.783 2.7582a.7712.7712 0 0 0 .7806 0l5.8428-3.3685v2.3324a.0804.0804 0 0 1-.0332.0615L9.74 19.9502a4.4992 4.4992 0 0 1-6.1408-1.6464zM2.3408 7.8956a4.485 4.485 0 0 1 2.3655-1.9728V11.6a.7664.7664 0 0 0 .3879.6765l5.8144 3.3543-2.0201 1.1685a.0757.0757 0 0 1-.071 0l-4.8303-2.7865A4.504 4.504 0 0 1 2.3408 7.872zm16.5963 3.8558L13.1038 8.364 15.1192 7.2a.0757.0757 0 0 1 .071 0l4.8303 2.7913a4.4944 4.4944 0 0 1-.6765 8.1042v-5.6772a.79.79 0 0 0-.407-.667zm2.0107-3.0231l-.142-.0852-4.7735-2.7818a.7759.7759 0 0 0-.7854 0L9.409 9.2297V6.8974a.0662.0662 0 0 1 .0284-.0615l4.8303-2.7866a4.4992 4.4992 0 0 1 6.6802 4.66zM8.3065 12.863l-2.02-1.1638a.0804.0804 0 0 1-.038-.0567V6.0742a4.4992 4.4992 0 0 1 7.3757-3.4537l-.142.0805L8.704 5.459a.7948.7948 0 0 0-.3927.6813zm1.0976-2.3654l2.602-1.4998 2.6069 1.4998v2.9994l-2.5974 1.4997-2.6067-1.4997Z"/>
        </svg>

        <form class="flex-1" @submit.prevent="handleSubmit">
          <fieldset class="relative disabled:text-gray-700" 
                    :disabled="payload.loading">
            <textarea class="w-full block resize-none py-2 px-3 bg-gray-50 border border-gray-200 rounded text-gray-600 pr-[50px] text-sm disabled:bg-gray-100 disabled:text-gray-700 disabled:ring-gray-200"
              ref="textarea" rows="1" name="message"
              placeholder="What code would you like to write?"
              style="max-height:300px;overflow-y:hidden;"
              :value="payload.message" v-model="payload.message"
              @input="$emit('update:data', $event.target.value); adjustHeight()"
              @keydown.escape="blurInput" @keydown.enter="handleEnter"
            />
            <button class="absolute bottom-0 right-0 my-[3px] mx-2 flex items-center justify-center rounded py-2 px-2 hover:enabled:bg-gray-200" type="submit">
              <svg class="h-4 w-4 animate-spin" 
                   xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24"
                   v-if="payload.loading">
                <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
              </svg>
              <svg class="w-4 h-4 text-gray-600" v-else
                   xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" d="M6 12L3.269 3.126A59.768 59.768 0 0121.485 12 59.77 59.77 0 013.27 20.876L5.999 12zm0 0h7.5" />
              </svg>
            </button>
          </fieldset>
        </form>
      </div>
    </div>
    `,

    data() {
      return {
        payload: payload
      };
    },

    computed: {},

    methods: {
      handleMessageChange({ target: { value } }) {
        ctx.pushEvent("update_message", value);
      },

      handleSubmit(e) {
        e.preventDefault();
        let data = new FormData(e.target);
        const message = data.get("message");
        if(message) {
          ctx.pushEvent("submit_message", message);
        }
      },

      blurInput(event) {
        event.target.blur();
      },
      
      handleEnter(event) {
        if (event.shiftKey) {
          event.stopPropagation();
          return;
        } else {
          // Otherwise, prevent newline and trigger form submit
          event.preventDefault();
          const newEvent = new Event("submit", {cancelable: true, target: event.target.form});
          event.target.form.dispatchEvent(newEvent);
        }
      },

      adjustHeight() {
        const textarea = this.$refs.textarea;
        textarea.style.height = 'auto'; // reset so we can get size
        let height = textarea.scrollHeight + 2;
        textarea.style.height = `${height}px`
      },
    },

    watch: {
      payload: {
        deep: true,
        handler(val) {
          Vue.nextTick(() => {
            this.adjustHeight();
          })
        },
      },
    },

  }).mount(ctx.root);

  ctx.handleEvent("update_loading", (loading) => {
    app.payload.loading = loading;
  });

  ctx.handleEvent("update_message", (message) => {
    app.payload.message = message;
  });

  ctx.handleEvent("update_errors", (errors) => {
    app.payload.errors = errors;
  });

  ctx.handleSync(() => {
    // Synchronously invokes change listeners
    document.activeElement &&
      document.activeElement.dispatchEvent(
        new Event("change", { bubbles: true })
      );
  });
}
