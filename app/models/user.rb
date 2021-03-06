class User < ApplicationRecord
    has_many :microposts, dependent: :destroy
    attr_accessor :remember_token, :activation_token
    before_save   :downcase_email
    before_create :create_activation_digest  
    validates :name, presence: true, length: {maximum: 50}, uniqueness: true
    VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
    validates :email, presence: true, length: {maximum: 250}, uniqueness: { case_sensitive: false },format: {with: VALID_EMAIL_REGEX}
    has_secure_password
    validates :password, presence: true, length: {minimum: 6}, allow_nil: true
    def User.digest(string)
      cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                    BCrypt::Engine.cost
      BCrypt::Password.create(string, cost: cost)
    end

    def feed
      Micropost.where("user_id = ?", id)
    end

    def self.find_or_create_from_auth_hash(auth)
      where(provider: auth.provider, uid: auth.uid).first_or_initialize.tap do |user|
        user.provider = auth.provider
        user.uid = auth.uid
        user.name = auth.info.first_name + " " + auth.info.last_name
        user.first_name = auth.info.first_name
        user.last_name = auth.info.last_name
        user.email = auth.info.email
        user.picture = auth.info.image
        user.password = SecureRandom.urlsafe_base64
        user.save!
      end
    end
  
    private

      def User.new_token
        SecureRandom.urlsafe_base64
      end

      def remember
        self.remember_token = User.new_token
        update_attribute(:remember_digest, User.digest(remember_token))
      end

      def authenticated?(attribute,token)
        digest = send("#{attribute}_digest")
        return false if digest.nil?
        BCrypt::Password.new(remember_digest).is_password?(remember_token)
      end
    # Converts email to all lower-case.
      def downcase_email
        self.email = email.downcase
      end

      # Creates and assigns the activation token and digest.
      def create_activation_digest
        self.activation_token  = User.new_token
        self.activation_digest = User.digest(activation_token)
      end
end
