Rails.application.routes.draw do
  get 'chatbot_intents/index', to: 'chatbot_intents#index'
  get 'chatbot_intents/consult_deposit', to: 'chatbot_intents#consult_deposit'
  get 'chatbot_intents/consult_indicators', to: 'chatbot_intents#consult_indicators'
  get 'chatbot_intents/deposit_details', to: 'chatbot_intents#deposit_details'
  post 'chatbot_intents/request_paper_rolls', to: 'chatbot_intents#request_paper_rolls'
end
