import logging
import pandas as pd

from fbprophet import Prophet


log = logging.getLogger()


def forecast(df: pd.DataFrame, periods=28) -> pd.DataFrame:
	log.info("Processing input.")

	df.columns = [col.lower() for col in df.columns]

	# rename according to prophets naming convention
	data = df.rename({"date": "ds"}, axis=1)
	data["ds"] = pd.to_datetime(data["ds"])

	log.info("Fitting model.")
	model = Prophet()
	model.fit(data)

	log.info("Computing predictions.")
	future_df = model.make_future_dataframe(periods=periods, include_history=False)
	forecast_df = model.predict(future_df)

	log.info("Processing output.")
	forecast_df = forecast_df.rename({"ds": "date", "yhat": "prediction"}, axis=1)
	forecast_df = forecast_df[["date", "prediction"]]

	return forecast_df
