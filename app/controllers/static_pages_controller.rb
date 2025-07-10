class StaticPagesController < ApplicationController
    
  require 'fedapay'

  def create

    begin
      # Configuration de l'API FedaPay
      FedaPay.api_key = 'sk_sandbox_XXXXXXXXXXXXXXXXXXXX'
      FedaPay.environment = 'env' # 'sandbox' ou 'live' en production
  
      # Création de la transaction
      transaction = FedaPay::Transaction.create(
        amount: 100000,
        currency: { iso: 'XOF' },
        callback_url: "http://rubysample.fedapay.com/payment_status",
        description: 'Achat de montre de luxe',
      )
  
      # Génération du token de la transaction
      token = transaction.generate_token
  
      # Redirection automatique vers la page de paiement
      redirect_to token.url, allow_other_host: true
  
      puts "Transaction successfully created : #{transaction.inspect}"
  
    rescue FedaPay::Error => e
      # Capture des erreurs spécifiques à FedaPay
      puts "FedaPay Error: #{e.message}"
      render json: { error: "Une erreur est survenue lors de la création de la transaction : #{e.message}" }, status: :unprocessable_entity
  
    rescue StandardError => e
      # Capture des erreurs générales
      puts "Standard Error: #{e.message}"
      render json: { error: "Unubysample.fedapay.come erreur inattendue est survenue. Veuillez réessayer plus tard." }, status: :internal_server_error
    end
  end
  

#Gestion des calbacks et statuts de la transaction
    def payment_status

      transaction_id = params[:id]
      
      if transaction_id.blank?
        flash[:alert] = "ID de transaction non fourni."
        redirect_to root_path and return
      end
    
      begin
        transaction = FedaPay::Transaction.retrieve(transaction_id)
        status = transaction.status
    
        flash[:notice] = if %w[approved transferred].include?(status)
                            "Paiement réussi !"
                          else
                            "Échec du paiement. Statut : #{status}"
                          end
      rescue StandardError => e
        flash[:alert] = "Erreur lors du traitement du paiement : #{e.message}"
      end
    
      redirect_to root_path
    end
    
  end
  