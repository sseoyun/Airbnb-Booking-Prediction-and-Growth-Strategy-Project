![image](https://github.com/user-attachments/assets/7b5a2cd5-fe86-47e5-996e-417579a539a0)<br>

# 1. 문제 설명
## 1.1 연구 배경
현대 사회에서 해외여행이나 교환학생 경험은 점차 증가하고 있으며, 많은 사람들이 에어비앤비와 같은 숙박 서비스를 활용하고 있다. 그러나 주변 지인들의 경험을 통해 발견된 것처럼, 모든 숙소에서 동일한 만족도를 느끼지 못하는 경우가 있다. 특히, 슈퍼호스트가 운영하는 숙소에서의 만족도가 높다는 인상을 받아, 슈퍼호스트 여부에 영향을 미치는 다양한 조건들이 무엇인지에 대한 궁금증이 생겼다. 이러한 경험을 바탕으로, 에어비앤비의 슈퍼호스트가 되기 위해서는 어떤 조건들이 중요한지 조사하는 연구가 필요하다고 생각이 들어 다음과 같은 주제를 정하게 되었다.
## 1.2 연구 목적
이 연구는 슈퍼호스트 여부와 접근성, 청결도 등 숙소 관련 변수들 간의 관계를 탐색하여 슈퍼호스트 여부에 영향을 미치는 변수들을 찾아 만족도가 낮은 숙소들의 개선 방안을 제시할 수 있으며, 에어비앤비 이용자들이 만족할 수 있는 더 나은 숙박 환경을 제공하기 위한 지침을 도출할 수 있을 것이다.
## 1.3 연구 질문
Airbnb, 어떻게 하면 고객을 만족시킬 수 있을까?

# 2. 데이터 출처 및 특징 설명
## 2.1 데이터 출처
Inside Airbnb는 Airbnb의 웹사이트에 등록되어 있는 숙소에 대한 정보를 추출하여 각 도시별로 종합한 자료를 대중에게 제공하고 있다. Airbnb의 공식 웹사이트에서 자료가 추출되었다는 점, 해당 자료에 가격 예측에 필요한 변수들인 가격, 숙소에 대한 위치 및 세부 정보, host에 대한 정보, 예약 관련 정보 등이 폭넓게 담겨 있다는 점, 실증적인 데이터를 제공한다는 점에서 본 프로젝트의 목적에 적절한 자료라고 판단된다. 74개의 columns중에 유의미하다고 판단되는 24개의 column들만 추출해 사용하였다. <br>
### 🔗http://insideairbnb.com/get-the-data/


## 2.2 데이터 요약 및 변수 설명
### 2.2.1 데이터 요약 및 변수 설명
<p align="center">
  <img src="https://github.com/user-attachments/assets/77473b99-80e9-4443-beb0-60aebf002ebd" alt="이미지 설명" />
</p>

27개의 변수와 87846개의 관측치를 가지고 있으며 변수 설명은 아래와 같다. 
| 변수명                     | 변수 설명                                                                         | 변수명                     | 변수 설명                                                                         |
|----------------------------|-----------------------------------------------------------------------------------|----------------------------|-----------------------------------------------------------------------------------|
| description                | 호스트가 작성한 숙소에 대한 설명                                                  | review_scores_accuracy     | 후기 점수 정확도                                                                  |
| beds                       | 숙소 침대의 개수                                                                  | review_scores_cleanliness  | 후기 점수 청결도                                                                  |
| host_since                 | 숙소 처음 등록 시점                                                               | review_scores_checkin      | 후기 점수 체크인                                                                  |
| amenities                  | 숙소에서 제공하는 편의시설, 물품 목록                                             | review_scores_communication| 후기 점수 의사소통                                                                |
| host_about                 | 호스트의 소개                                                                     | review_scores_location     | 후기 점수 위치                                                                    |
| price                      | 현지 통화로 1일 가격                                                              | latitude                   | 위도                                                                             |
| host_response_time         | 응답 시간(호스트가 게스트 요청에 응답하는 데 걸리는 시간)                         | longitude                  | 경도                                                                             |
| minimum_nights             | 숙소에 머무는 최소한의 박수 (캘린더 규칙은 다를 수 있음)                          | room_type                  | 숙소 유형                                                                         |
| host_response_rate         | 응답률                                                                            | accommodates               | 숙소의 최대 수용 인원                                                              |
| maximum_nights             | 숙소에 머무는 최대 박수 (캘린더 규칙은 다를 수 있음)                              | bathrooms_text             | 화장실 종류                                                                        |
| host_is_superhost          | 슈퍼호스트 여부                                                                   | instant_bookable           | 게스트가 호스트의 승인을 요청하지 않고 숙소를 자동으로 예약할 수 있는지 여부, 상업적 숙소의 지표 |
| number_of_reviews_ltm      | (지난 12개월 동안의) 숙소에 대한 리뷰의 수                                        | bedrooms                   | 숙소 침실의 개수                                                                  |
| host_total_listings_count  | 호스트가 보유한 숙소 수 (에어비앤비 계산 기준)                                    |           review_scores_rating     |     숙소 후기 점수                    |
| host_has_profile_pic       | 호스트 프로필에 사진 여부                                                         |                            |                                                                                   |

## 2.3 데이터 전처리
<p align="center">
  <img src="https://github.com/user-attachments/assets/899df905-27c8-4cbd-9183-276547e9bf51" alt="이미지 설명 2" />
</p>
이때 전체 데이터 value에 171591개의 결측치가 존재한다.
컬럼별 결측치를 확인하였을 때 bedrooms, review_scores_accuracy review_scores_cleanlines, review_scores_checkin, review_scores_communication, review_scores_location 변수에 결측치가 대부분 분포했다. 따라서 결측치가 너무 많은 bedrooms 변수를 삭제했으며 review_scores_accuracy, review_scores_cleanlines, 
review_scores_checkin, review_scores_communication, review_scores_location 변수의 결측치들은 정보가 없다고 가정하고 결측치가 있는 행을 모두 삭제하였다. 

아래 표는 결측치 처리 외에 전처리를 한 방법들이다. 
| 변수명                     | 전처리 방법                                                                   | 변수명                     | 전처리 방법                                                                   |
|----------------------------|-------------------------------------------------------------------------------|----------------------------|-------------------------------------------------------------------------------|
| description                | - 불용어를 처리 후 유의미한 단어의 개수를 셈                                   | review_scores_accuracy     |                                                                               |
| beds                       |                                                                               | review_scores_cleanliness  |                                                                               |
| host_since                 | - 데이터 최종 업데이트 일자를 기준으로 숙소를 처음 등록한 시점부터 현재까지의 일(days) 수를 계산 | review_scores_checkin      |                                                                               |
| amenities                  |                                                                               | review_scores_communication|                                                                               |
| host_about                 | - 불용어를 처리 후 유의미한 단어의 개수를 셈                                   | review_scores_location     |                                                                               |
| price                      | - $ 표시 빼고 수치형으로 바꿈                                                  | latitude                   |                                                                               |
|                            | - 이후 결측치 행은 정보가 없다 생각해 삭제                                      | longitude                  |                                                                               |
| host_response_time         | - N/A를 Noinfo로 바꿈                                                          | room_type                  | - 범주형으로 바꿈                                                              |
|                            | - 범주형으로 바꿈                                                              | accommodates               | 숙소의 최대 수용 인원                                                          |
| minimum_nights             |                                                                               | bathrooms_text             | - barthroom type에 상관없이 bathroom 개수만 셈                                |
|                            |                                                                               |                            | - 수치형으로 바꿈                                                              |
| host_response_rate         | - N/A를 0%로 바꿈                                                              | instant_bookable           | - 범주형으로 바꿈                                                              |
|                            | - 범주형으로 바꿈                                                              | bedrooms                   | - 앞에서 결측치 많아서 컬럼 자체 삭제                                          |
| maximum_nights             |                                                                               |                            |                                                                               |
| host_is_superhost          | - 범주형으로 바꿈                                                              |                            |                                                                               |
| number_of_reviews_ltm      |                                                                               |                            |                                                                               |
| host_total_listings_count  |                                                                               |                            |                                                                               |
| review_scores_rating       |                                                                               |                            |                                                                               |
| host_has_profile_pic       | - 범주형으로 바꿈                                                              |                            |                                                                               |





## 2.4 EDA
latitude와 longitude를 런던 지도에 슈퍼호스트 여부에 따라 표시하였을 때 큰 차이가 없어 두 변수를 먼저 삭제하였다. <부록1, 그림1> <br>
<p align="center">
  <img src="https://github.com/user-attachments/assets/a3b68443-39e3-4f61-8615-626a8ee5b86b" alt="부록1, 그림1" />
</p>

연속형 변수는 상자 그림, 범주형 변수는 범주별 수퍼호스트의 비율을 그래프로 나타냈다. hostresponse_time응답시간에 따라 슈퍼호스트 비율이 높아지는 모습을 보였고, <br>
<p align="center">
  <img src="https://github.com/user-attachments/assets/03c37f2a-c244-46f7-b6bb-1443b728060f" alt="그래프 1" />
</p>

entire와 private에서 다른 숙소 유형보다 슈퍼호스트 비율이 높게 나타난 것으로 보아 room_type, response_time이 슈퍼호스트 여부에 영향을 미칠 것이라고 생각한다. <br>
연속형 변수들의 상자 그림을 보았을 때 이상치 처리가 필요한 변수들은 description, host_since, host_total_listings_count, amenities, price, minimum_nights, maximum_nights로 나타났다. <부록1, 그림2> <br>

<br>
<p align="center">
  <img src="https://github.com/user-attachments/assets/ef0cd05e-14f7-4393-b7f8-5da1bace39b9" alt="부록1, 그림2" />
</p>

또한, 슈퍼호스트 여부에 영향을 미치는 변수만을 파악한 것이 아니라 이상치 등 일반적이지 않은 관측치들도 발견하였다. <br>
<p align="center">
  <img src="https://github.com/user-attachments/assets/a9e8fa8f-611b-4e2d-accd-0f1eae1a70ad" alt="그래프 2" />
</p>

숙소 총 평점을 나타내는 review_scores_rating 변수의 상자 그림에서는 슈퍼호스트(1)인데 4.8점 미만인 이상한 값들이 관측되었다. <br>
더불어 세부적인 숙소 후기 점수를 나타내는 review_scores_accuracy, review_scores_cleanlines, review_scores_checkin, review_scores_communication, review_scores_location 변수의 상자 그림에서 0점인 값들이 발견되었다. <부록1, 그림3> 
화장실 개수를 나타내는 bathrooms_text의 상자 그림에서는 화장실 개수가 0인 경우와 화징실이 48개인 경우도 있다. <br>
<p align="center">
  <img src="https://github.com/user-attachments/assets/fd2919e0-c328-4de1-b260-c5bf3fc261b5" alt="부록1, 그림3" />
</p>

위 상관관계 그림을 보면 beds와 accommodate가 높은 상관관계를 보이고 있으며 bathrooms_text와 accomodate도 높은 상관관계를 보이고 있다.


## 2.5 추가 전처리 
앞에서 EDA 시각화를 통해 발견된 일반적이지 않은 관측치들을 추가로 처리하였다. 
이상치가 발견된 description, host_since, host_total_listings_count, amenities, price, minimum_nights, maximum_nights 변수들에서 이상치가 포함된 행들을 삭제했다. price는 해석 용이성을 위해 로그 변환까지 해주었다. 슈퍼호스트(host_is_superhost=1)인데 4.8점 미만인 이상한 값들을 삭제하였으며 bathrooms_text 변수의 최고 값 행을 삭제하였으며 화장실 개수가 0인 숙소는 일반적이지 않다고 판단하여 0개인 행들도 삭제하였다. review_scores_rating, 
review_scores_accuracy, review_scores_cleanlines, review_scores_checkin, 
review_scores_communication, review_scores_location 변수의 값이 0인 행들도 모두 삭제하였다. 

상관관계 그림에서 accommodate 변수와 높은 상관관계를 보였던 beds 변수를 삭제하였다. 그리고 bathrooms_text 변수는 accommodates를 bathrooms_tex로 나눠 화장실 1개당 수용 인원을 나타내는 변수로 변환해 다중공선성을 해결하고자 하였다. 

## 2.6 최종 데이터 요약
<p align="center">
  <img src="https://github.com/user-attachments/assets/4995a7ed-4862-4d9b-ac16-559de7d8fcc1" alt="이미지 설명" />
</p>
최종 데이터의 상관관계 그림을 확인했을 때 처음 데이터보다 설명 변수들끼리 높은 상관관계를 나타내는 다중공선성 문제가 많이 개선된 것처럼 보이지만 review_scores관련 변수들끼리 높은 상관관계가 나타내는 것을 보인다. 따라서 뒤 모델 생성 과정에서 기존 변수들의 선형조합으로 새로운 변수를 만드는 PCA(주성분 분석) 방법을 통해 해결하고자 한다. 

# 3. 분석 모형 및 의미 설명
앞에서 언급한 것처럼
<p align="center">
  <img src="https://github.com/user-attachments/assets/9bf141cf-c1ec-430c-b6e4-d434ce3f33fc" alt="이미지 1" />
</p>
<p align="center">
  <img src="https://github.com/user-attachments/assets/edde4aab-0959-4218-8e16-4b38db162d0b" alt="이미지 2" />
</p>

review_scores_accuracy, review_scores_cleanlines, review_scores_checkin, 
review_scores_rating, review_scores_communication, review_scores_location의 여러 선형 조합에서 PCA 결과에 따라 누적 분산 비율이 72퍼센트인 제 1 주성분을 사용한다. 

<p align="center">
  <img src="https://github.com/user-attachments/assets/02783fe4-8871-4453-bb78-1737a008b898" alt="이미지 설명" />
</p>
이에 따라 제 1 주성분의 계수들을 곱해 각 변수에 곱해 새로운 변수 review_scores_rating를 만들었다. 

최종적으로 비교할 모델0, 1, 2, 3을 생성했다. 
모델 0은 이상치만 처리한 상태이다. 즉, price에서 로그 변환을 하지 않고, bathrooms_text를 화장실 당 수용인원으로 변수변환 하지 않았다. 모델 1에는 price 로그변환 bathrooms_text를 화장실 당 수용 인원으로 변수변환 하였으며 모델 2에는 모델 1 상태에서 기존 reviews_scores 변수들을 삭제하고 PCA로 만든 변수를 적용하였다. 이때 모델 3은 모델 2에 후진선택법을 사용해 변수를 선택하고자 하였는데 선택된 변수가 모델 1과 동일했다. 그래서 모델 3은 모델 2를 deviance 진단을 하였을 때(<부록 2>, 그림1)유일하게 유의하지 않은 변수인 maximum_nights 변수를 제거해 보았다. 

<모델 비교>
| 변수                           | 모델 0          | 모델 1          | 모델 2          | 모델 3          |
|--------------------------------|-----------------|-----------------|-----------------|-----------------|
| description                    | 4.209e-03***    | 4.116e-03***    | 3.309e-03***    | 3.348e-03***    |
| host_since                     | 1.319e-04***    | 1.343e-04***    | 1.240e-04***    | 1.254e-04***    |
| host_about                     | 5.187e-03***    | 5.247e-03***    | 4.868e-03***    | 4.890e-03***    |
| host_response_timeNoInfo       | 7.006e-01*      | 7.376e-01**     | 6.843e-01*      | 6.883e-01*      |
| host_response_time within a day| -7.047e-01.     | -7.916e-01*     | -7.471e-01*     | -7.408e-01*     |
| host_response_time within a few hours | -4.167e-01  | -5.040e-01      | -4.560e-01      | -4.480e-01      |
| host_response_time within an hour | -1.126e-02    | -2.118e-01      | -1.686e-01      | -1.596e-01      |
| host_response_rate             | 3.139e-02***    | 3.233e-02***    | 3.169e-02***    | 3.151e-02***    |
| host_total_listings_count      | 8.158e-03.      | 7.690e-03.      | -6.147e-03      | -5.837e-03      |
| host_has_profile_pic1          | 2.876e-01*      | 3.131e-01**     | 2.957e-01*      | 2.954e-01*      |
| room_typeHotel room            | -1.221e+00      | -1.605e+00.     | -1.689e+00*     | -1.650e+00*     |
| room_typePrivate room          | 5.012e-01***    | 5.548e-01***    | 5.043e-01***    | 5.023e-01***    |
| room_typeShared room           | -6.270e-01.     | -5.341e-01      | -6.612e-01.     | -6.519e-01.     |
| accommodates                   | -1.150e-01***   | -1.513e-01***   | -1.285e-01***   | -1.283e-01***   |
| bathrooms_text (화장실 당 수용인원) | 6.288e-02**  | 5.092e-02**     | 5.205e-02**     |                 |
| bathrooms_text (화장실 개수)   |                 |                 | -1.836e-01***   |                 |
| amenities                      | 2.013e-02***    | 1.976e-02***    | 2.247e-02***    | 2.253e-02***    |
| log(price)                     | 3.894e-01***    | 2.704e-01***    | 2.708e-01***    |                 |
| price                          | 3.309e-03***    |                 |                 |                 |
| minimum_nights                 | 9.079e-02***    | 8.628e-02***    | 9.311e-02***    | 9.238e-02***    |
| maximum_nights                 | 1.523e-04***    | 1.754e-04***    | 1.191e-04***    |                 |
| number_of_reviews_ltm          | 5.532e-02***    | 5.531e-02***    | 4.616e-02***    | 4.618e-02***    |
| review_scores_rating           | 7.031e+00***    | 6.932e+00***    |                 |                 |
| review_scores_accuracy         | 5.311e-01***    | 5.201e-01***    |                 |                 |
| review_scores_cleanliness      | 6.185e-01***    | 6.302e-01***    |                 |                 |
| review_scores_checkin          | 2.318e-01.      | 2.627e-01*      |                 |                 |
| review_scores_communication    | 1.086e+00***    | 1.041e+00***    |                 |                 |
| review_scores_location         | -4.506e-01***   | -4.178e-01***   |                 |                 |
| instant_bookable1              | -1.582e-01***   | -1.490e-01***   | -1.604e-01***   | -1.599e-01***   |
| review_scores                  |                 | 1.661e+00***    | 1.651e+00***    |                 |
| constant                       | -5.084e+01***   | -5.215e+01***   | -4.869e+01***   | -4.840e+01***   |
| AIC                            | 23990           | 25910           | 26972           | 26984           |
** 자세한 모델 결과는 <부록2, 그림2>, <부록2, 그림3>,<부록2, 그림4>, <부록2, 그림5> 참고 **

최종적으로 선택한 모형은 모델 3이다. 

<p align="center">
  <b><모델 3></b> <br>
  <img src="https://github.com/user-attachments/assets/07358db2-bbfa-469e-a35f-9385b095d2f3" alt="모델 3 이미지" />
</p>

<p align="center">
  <b><모델 3 수치형 변수들의 상관관계></b> <br>
  <img src="https://github.com/user-attachments/assets/147e1660-5ed3-43cc-8ee2-4e679539775b" alt="모델 3 수치형 변수들의 상관관계 이미지" />
</p>

최종적으로 모델 3을 선택하였다. 3개의 모델을 비교해보면 모델 3의 AIC가 제일 높지만 변수 제거로 인한 불가피한 AIC 증가라고 생각하였다. 따라서 변수 제거로 인해 모델을 더 간단하게 만들면서도 해당 변수들이 모델의 중요한 정보를 유지한다고 판단해 모델 3을 선택하였다.

최종적인 모델 3을 해석해보자. 
먼저 유의미한 양의 계수를 가진 변수들을 해석하면, 
description인 호스트가 설명하는 숙소 소개가 길수록
host_since인 숙소를 등록한 시점이 과거일수록 
host_about인 호스트의 소개가 길수록
host_response_timeNoInfo인 응답 시간에 대한 정보가 없는 경우가 
host_response_rate인 응답률이 높을수록 
host_has_profile_pic1인 호스트의 프로필이 있는 경우가 없는 경우보다
room_typePrivate room인 숙소 유형이 개인 유형인 경우가 아닌 경우보다 
bathrooms_text인 화장실당 수용 인원이 많을수록 
amenities인 숙소에서 제공하는 물품이나 편의시설이 많을수록
price인 현지 통화 가격이 높을수록 
minimum_nights인 최소 숙박 일수가 높을수록
number_of_reviews_ltm인 1년 이내의 숙소 리뷰의 수가 많을수록 
reviews_scores가 높을수록 슈퍼호스트일 확률이 높아진다고 해석할 수 있다. 

다음으로 유의한 음의 계수를 가진 변수들을 해석하면, 
instant_bookable1인 즉시 예약할 수 있는 경우가 없는 경우보다 
host_response_timewithin a day인 하루 안으로 답장하는 경우가 아닌 경우보다 
room_typeHotel room인 숙소유형이 호텔인 경우가 아닌 경우보다 
room_typeShared room인 숙소 유형이 여러 사람이 함께 쓰는 경우가 아닌 경우보다 
accommodates인 최대 수용 인원 수가 많을수록 슈퍼호스트일 확률이 낮을 것이라고 해석할 수 있다. 

# 4. 분석에 대한 검토 및 한계점, 우수성 설명
## 4.1 우수성 
분석에 사용된 데이터는 코로나 이후의 최신 자료이며, 에어비앤비와 같은 관심 플랫폼에 대한 전략을 이해하는 데 중요한 정보를 제공한다. 

## 4.2 한계점
4.2.1 데이터 측면
전체 데이터를 사용한 것은 특정 기간에 대한 표본이 아니라 모집단을 대표하는 것이 아니기 때문에, 결과의 일반화에 한계가 있을 수 있다. 

## 4.3 모델 측면
모델링 시 생길 수 있는 중요한 제약으로는 omitted variable 문제와 슈퍼호스트의 명확한 기준이 review로 제외되었을 때, 다른 변수들의 영향을 명확히 이해하기 어렵다는 것이 있다.





# 📝추가 분석
“숙소 후기 평점이 4.8 이상인데 왜 슈퍼호스트가 아닐까?”라는 추가 궁금증이 들어 숙소 후기 평점이 4.8 이상인 데이터만 추출해 추가 분석을 진행해보았다. <br>

<p align="center">
  <img src="https://github.com/user-attachments/assets/1ed21442-8b3c-4f8b-a43c-510596fb75bf" alt="그래프 1" />
</p>
호스트의 응답률을 나타내는 host_response_rate가 슈퍼호스트가 아닌 경우 평균이 훨씬 낮은 것을 보아 응답률이 낮아서 슈퍼호스트가 안 된 것으로 추측할 수 있다. <br>

<p align="center">
  <img src="https://github.com/user-attachments/assets/4d2b6d90-ace5-4005-9c66-7539a5675cf6" alt="그래프 2" />
</p>
더불어 숙소가 제공하는 편의시설이나 물품 개수를 나타내는 ammenities가 슈퍼호스트가 아닌 경우보다 작은 값으로 분포되어 있는 것으로 보아 물품 개수가 적어서 슈퍼호스트가 안 된 것으로 추측할 수 있다. <br>

<p align="center">
  <img src="https://github.com/user-attachments/assets/2e8ffccf-015c-4fee-a634-8645054085ea" alt="그래프 3" />
</p>
화장실당 수용 인원 수를 나타내는 변수 bathrooms_text에서도 슈퍼호스트인 경우 좀 더 화장실당 인원이 적은 것을 볼 수 있다. <br>





