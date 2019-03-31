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

  def self.sign_in_with_facebook(email,customer_id,name)

    user = User.find_by(email: email)

    #存在する場合は削除する
    if user != nil
      user.destroy
    end

    # Slorn-webにレコードを作成する
    @user = User.create(
      uid:      nil,
      provider: 'FB',
      email:    email,
      name:     name,
      password: "hogehoge",
      encrypted_password: Digest::MD5.hexdigest("hogehoge"),
      image:  nil,
      confirmed_at: Time.now.utc,
      customer_id: customer_id
    ) # User.createはsaveまでやってくれる

  end

  def self.create_email_user(email, customer_id, name, encrypted_password)

    user = User.create(
      uid:      nil,
      provider: nil,
      email:    email,
      name:  name,
      password: "yellow",
      encrypted_password: encrypted_password,
      image:  nil,
      confirmed_at: Time.now.utc,
      customer_id: customer_id
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

   user

  end

end
