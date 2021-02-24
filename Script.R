

rm(list=ls())
options(OutDec = ',')


## Pacotes ---------------------------------------------------------------------

if(!require(readr)){install.packages('readr'); require(readr)}
if(!require(tidyverse)){install.packages('tidyverse'); require(tidyverse)}
if(!require(forcats)){install.packages('forcats'); require(forcats)}
if(!require(gtsummary)){install.packages('gtsummary'); require(gtsummary)}



## Leitura e manipulação dos dados ---------------------------------------------

aeronave <- read_csv2('dados/aeronave.csv')
fator_contribuinte <- read_csv2('dados/fator_contribuinte.csv')
ocorrencia <- read_csv2('dados/ocorrencia.csv')
reportes_2011_2019 <- read.csv2('dados/reportes_2011_2019.csv')


aeronave <- aeronave %>% 
  apply(2, function(x) ifelse(x == '', NA, x)) %>% 
  data.frame()

fator_contribuinte <- fator_contribuinte %>% 
  apply(2, function(x) ifelse(x == '', NA, x)) %>% 
  data.frame()

ocorrencia <- ocorrencia %>% 
  apply(2, function(x) ifelse(x == '', NA, x)) %>% 
  data.frame()

reportes_2011_2019 <- reportes_2011_2019 %>% 
  apply(2, function(x) ifelse(x == '', NA, x)) %>% 
  data.frame()


#### Juntando banco de dados

dados <- aeronave %>% 
  transmute(codigo_ocorrencia = codigo_ocorrencia2,
            
            aeronave_operador_categoria = case_when(
              aeronave_operador_categoria == '***' ~ NA_character_,
              TRUE ~ aeronave_operador_categoria),
            
            aeronave_operador_categoria = fct_lump(aeronave_operador_categoria, 
                                                   2, 
                                                   other_level = 'Outros'),
            
            aeronave_tipo_veiculo = case_when(
              aeronave_tipo_veiculo == '***' ~ NA_character_,
              TRUE ~ aeronave_tipo_veiculo),
            
            aeronave_tipo_veiculo = fct_lump(aeronave_tipo_veiculo, 
                                             2, 
                                             other_level = 'Outros'),
            
            aeronave_motor_tipo = case_when(
              aeronave_motor_tipo == '***' ~ NA_character_,
              TRUE ~ aeronave_motor_tipo),
            
            aeronave_motor_quantidade = case_when(
              aeronave_motor_quantidade == '***' ~ NA_character_,
              TRUE ~ aeronave_motor_quantidade),
            
            aeronave_motor_quantidade = fct_lump(aeronave_motor_quantidade, 
                                                 2, 
                                                 other_level = 'Outros'),
            
            aeronave_assentos = case_when(
              aeronave_assentos == 'NULL' ~ NA_character_,
              TRUE ~ aeronave_assentos),
            
            aeronave_assentos = as.numeric(aeronave_assentos),
            
            aeronave_ano_fabricacao = case_when(
              aeronave_ano_fabricacao != 0 ~ aeronave_ano_fabricacao),
            
            aeronave_ano_fabricacao = as.numeric(aeronave_ano_fabricacao),
            
            aeronave_pais_fabricante = case_when(
              aeronave_pais_fabricante == '***' ~ NA_character_,
              TRUE ~ aeronave_pais_fabricante),
            
            aeronave_pais_fabricante = fct_lump(aeronave_pais_fabricante, 
                                                1, 
                                                other_level = 'Outros'),
            
            aeronave_registro_segmento = case_when(
              aeronave_registro_segmento == '***' ~ NA_character_,
              TRUE ~ aeronave_registro_segmento),
            
            aeronave_registro_segmento = fct_lump(aeronave_registro_segmento, 
                                                  4, 
                                                  other_level = 'Outros'),
            
            aeronave_tipo_operacao = case_when(
              aeronave_tipo_operacao == '***' ~ NA_character_,
              TRUE ~ aeronave_tipo_operacao),
            
            aeronave_tipo_operacao = fct_lump(aeronave_tipo_operacao, 
                                              4, 
                                              other_level = 'Outros'),
            
            aeronave_nivel_dano = case_when(
              aeronave_nivel_dano == '***' ~ NA_character_,
              TRUE ~ aeronave_nivel_dano),
            
            aeronave_fatalidades_total = as.numeric(aeronave_fatalidades_total)) %>% 
  left_join(fator_contribuinte %>% 
              transmute(
                codigo_ocorrencia = codigo_ocorrencia3,
                fator_condicionante = case_when(
                  fator_condicionante == '***' ~ NA_character_,
                  TRUE ~ fator_condicionante),
                
                fator_condicionante = fct_lump(fator_condicionante, 
                                               2, 
                                               other_level = 'Outros'),
                
                fator_area = case_when(
                  fator_area == '***' ~ NA_character_,
                  TRUE ~ fator_area)
              ), by = 'codigo_ocorrencia') %>% 
  left_join(ocorrencia %>% 
              transmute(codigo_ocorrencia,
                        
                        ocorrencia_classificacao,
                        
                        investigacao_aeronave_liberada = case_when(
                          investigacao_aeronave_liberada == '***'|
                            investigacao_aeronave_liberada == 'NULL' ~ NA_character_,
                          TRUE ~ investigacao_aeronave_liberada),
                        
                        investigacao_status = case_when(
                          investigacao_status == 'NULL' ~ NA_character_,
                          TRUE ~ investigacao_status),
                        
                        divulgacao_relatorio_publicado,
                        
                        total_recomendacoes = as.numeric(total_recomendacoes),
                        
                        total_aeronaves_envolvidas = as.numeric(total_aeronaves_envolvidas),
                        
                        ocorrencia_saida_pista), 
            by = 'codigo_ocorrencia') %>% 
  left_join(reportes_2011_2019 %>% 
              transmute(codigo_ocorrencia = codigo_reporte,
                        
                        tipo_reporte,
                        
                        aviaco_tipo,
                        
                        condicao_ceu,
                        
                        danos_prejuizo = case_when(
                          danos_prejuizo == 'Indeterminado'|
                            danos_prejuizo == 'Não informado' ~ NA_character_,
                          TRUE ~ danos_prejuizo),
                        
                        fase_voo,
                        
                        lado,
                        
                        periodo_dia,
                        
                        precipitacao = case_when(
                          precipitacao == 'Chuva recente'|
                            precipitacao == 'Chuva'|
                            precipitacao == 'Nevoeiro'|
                            precipitacao == 'sim' ~ 'Sim',
                          precipitacao == 'nao'|
                            precipitacao == 'Nenhuma' ~ 'Não',
                          precipitacao == 'Nenhuma' ~ 'Não'),
                        
                        velocidade = as.numeric(velocidade),
                        
                        altura = as.numeric(altura),
                        
                        asa), 
            by = 'codigo_ocorrencia')


colnames(dados) <- c('codigo_ocorrencia',
                     'Categoria do operador',
                     'Tipo do veiculo',
                     'Tipo do motor',
                     'Quantidade de Motor',
                     'Quantidade de assentos',
                     'Ano de fabricação',
                     'País fabricante',
                     'Registro de Segmento',
                     'Tipo de operacao',
                     'Nivel do dano',
                     'Total de fatalidades',
                     'Fator condicionante',
                     'Fator àrea',
                     'Classificação da ocorrência',
                     'Aeronave liberadada investigação',
                     'Status de investigação',
                     'Divulgação do relatório publicado',
                     'Total de recomendações',
                     'Total de aeronaves envolvidas',
                     'Saiu da pista',
                     'Tipo de Reporte',
                     'Tipo de avião',
                     'Condição do ceu',
                     'Danos e prejuizos',
                     'Fase do voo',
                     'Lado',
                     'Período do dia',
                     'Precipitação',
                     'Velocidade',
                     'Altura',
                     'Asa')



## Análise descritiva ----------------------------------------------------------

#### Variáveis categóricas

dados %>% 
  select(`Categoria do operador`,
         `Tipo do veiculo`,
         `Tipo do motor`,
         `Quantidade de Motor`,
         `País fabricante`,
         `Registro de Segmento`,
         `Tipo de operacao`,
         `Nivel do dano`,
         `Fator condicionante`,
         `Fator àrea`,
         `Classificação da ocorrência`,
         `Aeronave liberadada investigação`,
         `Status de investigação`,
         `Divulgação do relatório publicado`, 
         `Total de aeronaves envolvidas`,
         `Saiu da pista`,
         `Tipo de Reporte`,
         `Tipo de avião`,
         `Condição do ceu`,
         `Danos e prejuizos`,
         `Fase do voo`,
         Lado,
         `Período do dia`,
         Precipitação,
         Asa) %>% 
  tbl_summary(
    missing =  'no') %>% 
  modify_header(update =list(label  ~  "**Variáveis**")) %>% 
  bold_labels() %>%
  modify_footnote(everything() ~ NA_character_) 



#### Variáveis numéricas

t1 <- dados %>% 
  select(`Quantidade de assentos`, 
         `Ano de fabricação`, 
         `Total de fatalidades`, 
         `Total de recomendações`,
         Velocidade,
         Altura) %>%   
  tbl_summary(statistic = all_continuous() ~ "{mean}", 
              missing = "no",
              digits = list(all_continuous()~ 2)) %>%
  modify_header(stat_0 ~ "**Média**") %>% add_n() 

t2 <- dados %>% 
  select(`Quantidade de assentos`, 
         `Ano de fabricação`, 
         `Total de fatalidades`, 
         `Total de recomendações`, 
         Velocidade,
         Altura) %>%
  tbl_summary(statistic = all_continuous() ~ "{sd}", 
              missing = "no",
              digits = list(all_continuous()~ 2)) %>%
  modify_header(stat_0 ~ "**S.D.**") 

tbl_merge(list(t1, t2)) %>% 
  modify_header(update = list(label ~ "**Variáveis**")) %>% 
  modify_footnote(everything() ~ NA_character_) %>% 
  modify_spanning_header(everything() ~ NA_character_)



## Análise de dados faltantes --------------------------------------------------

dados.na <- dados %>% 
  sapply(., function(x) sum(is.na(x))) %>% 
  data.frame()

dados.na <- dados.na %>% mutate(variavel = rownames(dados.na),
                                quant_na = dados.na$.,
                                porc = quant_na/(dim(dados)[1])) %>% 
  select(-.) %>% 
  filter(quant_na != 0) %>% 
  arrange(porc)

naniar::gg_miss_var(dados, show_pct = TRUE) + 
  labs(y = "Porcentagem de dados faltantes", x = "") + 
  ylim(0,100)



## Modelo de Poisson -----------------------------------------------------------

## Excluindo variáveis com mais de 25% de dados faltantes

dados_modelo <- dados %>% 
  select(`Tipo do veiculo`,
         `Tipo do motor`,
         `Quantidade de Motor`,
         `País fabricante`,
         `Registro de Segmento`,
         `Tipo de operacao`,
         `Nivel do dano`,
         `Classificação da ocorrência`,
         `Status de investigação`,
         `Divulgação do relatório publicado`, 
         `Total de aeronaves envolvidas`,
         `Saiu da pista`,
         `Tipo de Reporte`,
         `Condição do ceu`,
         `Fase do voo`,
         `Período do dia`,
         Precipitação,
         Asa,
         `Quantidade de assentos`, 
         `Ano de fabricação`, 
         `Total de fatalidades`, 
         `Total de recomendações`) %>% 
  filter(`Total de fatalidades` != 0)

caret::nearZeroVar(dados_modelo %>% 
                     na.omit())

dados_modelo %>% 
  select(4, 8, 9, 10, 11, 12, 18) %>% 
  names()

caret::findLinearCombos(dados_modelo %>% 
                          data.matrix %>% 
                          na.omit())



## Modelo inicial --------------------------------------------------------------

modelo_inicial <- glm(`Total de fatalidades` ~ 
                        `Tipo do veiculo` +
                        `Tipo do motor` +
                        `Quantidade de Motor` +
                        `Registro de Segmento` +
                        `Tipo de operacao` +
                        `Nivel do dano` +
                        `Tipo de Reporte` +
                        `Condição do ceu` +
                        `Período do dia` +
                        Precipitação +
                        `Ano de fabricação` + 
                        `Total de recomendações`,
                      family = 'poisson',
                      data = dados_modelo,
                      control = list(maxit = 1000))

options(OutDec = '.')

modelo_inicial %>% 
  tbl_regression(
    pvalue_fun = ~style_pvalue(.x, digits = 3),
    exponentiate = TRUE) %>% 
  modify_header(update = list(label ~ "**Variáveis**")) %>% 
  bold_labels() %>% 
  bold_p(t = 0.05)



## Modelo final ----------------------------------------------------------------

attributes(alias(modelo_inicial)$Complete)$dimnames[[1]]

modelo_final <- glm(`Total de fatalidades` ~ 
                      `Tipo do veiculo` +
                      `Tipo do motor` +
                      `Registro de Segmento` +
                      `Nivel do dano` +
                      `Tipo de Reporte` +
                      `Período do dia` + 
                      `Total de recomendações`,
                    family = 'poisson',
                    data = dados_modelo,
                    control = list(maxit = 1000),
                    singular.ok = TRUE)


modelo_final %>% 
  tbl_regression(
    pvalue_fun = ~style_pvalue(.x, digits = 3),
    exponentiate = TRUE) %>% 
  modify_header(update = list(label ~ "**Variáveis**")) %>% 
  bold_labels() %>% 
  bold_p(t = 0.05)

