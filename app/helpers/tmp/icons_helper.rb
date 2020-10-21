module Tmp::IconsHelper
  # rubocop:disable Layout/LineLength
  # rubocop:disable Rails/OutputSafety
  def reputation_icon(color:)
    '
    <svg width="32" height="32" viewBox="0 0 32 32" fill="none" xmlns="http://www.w3.org/2000/svg">
    <path d="M16.67 7H15.33C14.1 8.765 11.28 10 8 10V15.033C8.00014 17.0231 8.66553 18.9561 9.89038 20.5247C11.1152 22.0933 12.8293 23.2074 14.76 23.69L16 24L17.24 23.69C19.1707 23.2074 20.8848 22.0933 22.1096 20.5247C23.3345 18.9561 23.9999 17.0231 24 15.033V10C20.72 10 17.905 8.765 16.67 7Z" stroke="<COLOR>" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
    <path d="M15.47 12.17L14.752 14.14L12.321 14.47C12.2499 14.468 12.1801 14.4893 12.1221 14.5305C12.0642 14.5718 12.0213 14.6308 11.9999 14.6987C11.9785 14.7665 11.9799 14.8395 12.0037 14.9065C12.0275 14.9735 12.0726 15.0309 12.132 15.07L13.832 16.427L13.414 18.678C13.3954 18.7459 13.3986 18.8178 13.4229 18.8838C13.4473 18.9498 13.4917 19.0065 13.5499 19.0459C13.6081 19.0854 13.6772 19.1057 13.7475 19.1039C13.8179 19.1021 13.8859 19.0784 13.942 19.036L15.887 17.526L17.887 18.966C17.9443 19.0071 18.0131 19.029 18.0836 19.0287C18.154 19.0284 18.2226 19.0059 18.2796 18.9644C18.3365 18.9228 18.3789 18.8644 18.4007 18.7974C18.4225 18.7303 18.4226 18.6581 18.401 18.591L17.901 16.355L19.552 14.939C19.6086 14.8974 19.6503 14.8386 19.6709 14.7714C19.6915 14.7042 19.6899 14.6322 19.6663 14.566C19.6427 14.4998 19.5985 14.4429 19.54 14.4038C19.4816 14.3648 19.4122 14.3456 19.342 14.349L16.9 14.1L16.113 12.156C16.0872 12.0909 16.0421 12.0353 15.9838 11.9966C15.9254 11.9578 15.8566 11.9379 15.7866 11.9394C15.7166 11.9409 15.6488 11.9639 15.5922 12.0051C15.5356 12.0463 15.4929 12.1039 15.47 12.17Z" fill="<COLOR>"/>
    <path d="M1 10H5" stroke="<COLOR>" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
    <path d="M2 13H5" stroke="<COLOR>" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
    <path d="M3 16H5" stroke="<COLOR>" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
    <path d="M4 19H6" stroke="<COLOR>" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
    <path d="M31 10H27" stroke="<COLOR>" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
    <path d="M30 13H27" stroke="<COLOR>" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
    <path d="M29 16H27" stroke="<COLOR>" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
    <path d="M28 19H26" stroke="<COLOR>" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
    </svg>
    '.gsub("<COLOR>", color).html_safe
  end
  # rubocop:enable Layout/LineLength
  # rubocop:enable Rails/OutputSafety
end