use 5.014001;
use warnings;
use utf8;

return +{
    param => {
        email => 'メールアドレス',
    },
    function => {
      unique      => "その[_1]は既に登録されています",
      not_null    => "[_1]を入力してください",
      duplication => "[_1]は同じものを二回入力してください",
      email       => "[_1]がEメールアドレスとして正しくありません",
      date        => "[_1]が日付として正しくありません",
      not_sp      => "[_1]は半角スペースを含むことができません",
      int         => "[_1]は整数で入力してください",
      uint        => "[_1]は正の整数で入力してください",
      decimal     => "[_1]は実数で入力してください",
      udecimal    => "[_1]は正の実数で入力してください",
      too_large   => "[_1]が大きすぎます",
      regex       => "[_1]が正しくありません",
      tel         => "[_1]が電話番号として正しくありません",
      katakana    => "[_1]はカタカナで入力してください",
      http_url    => "[_1]がURLとして正しくありません",
      email       => "[_1]がメールアドレスとして正しくありません",
      email_loose => "[_1]がメールアドレスとして正しくありません",
    },
    message => {
      'file.not_null'  => ' please upload the file.',
      'email.email_loose' => "メールアドレスが正しくありません",
    },
};
