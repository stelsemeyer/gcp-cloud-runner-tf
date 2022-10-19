import logging
import pandas as pd
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import balanced_accuracy_score



log = logging.getLogger()
def forecast(df: pd.DataFrame) -> pd.DataFrame:
 log.info("Processing input.")
	#splitting to train and test data
 data_train, data_test = []
 data_train = df.loc[:"2022-05-31"]
 data_test = df.loc["2022-05-31":]
 data_test = data_test.iloc[1:, :]
 X_train = data_train.iloc[:, [1, -3]].values
 y_train = data_train.iloc[:, -1].values
 X_test = data_test.iloc[:, [1, -3]].values
 y_test = data_test.iloc[:, -1].values
 log.info("Fitting model.")
 logisticRegr = LogisticRegression()
 logisticRegr.fit(X_train, y_train)
 log.info("Computing predictions.")
 y_pred = logisticRegr.predict(X_test)
 log.info("Processing output.")
 balanced_acc = balanced_accuracy_score(y_test,y_pred)
 return balanced_acc

