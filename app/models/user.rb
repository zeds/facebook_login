class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :confirmable, :omniauthable, :encryptable

  validates :name, presence: true, length: { minimum: 1 }

  def self.check_user_for_oauth(auth)
    user = User.where(uid: auth.uid, provider: auth.provider).first
  end

  def self.create_email_user(email)
    user = User.create(
      uid:      nil,
      provider: nil,
      email:    email,
      name:  "hogehoge",
      password: Devise.friendly_token[0, 20],
      image:  nil,
      confirmed_at: Time.now
    ) # User.createはsaveまでやってくれる

  end


  def self.find_for_oauth(auth)
   user = User.where(uid: auth.uid, provider: auth.provider).first

   unless user
     user = User.create(
       uid:      auth.uid,
       provider: auth.provider,
       email:    auth.info.email,
       name:  auth.info.name,
       password: Devise.friendly_token[0, 20],
       image:  auth.info.image
     ) # User.createはsaveまでやってくれる

     flash[:success] = "ユーザー登録しました"
     redirect_to new_user_session_path
   end

   @user

  end

end
