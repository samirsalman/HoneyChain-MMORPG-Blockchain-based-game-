using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Soudrack : MonoBehaviour
{
    // Start is called before the first frame update

    private void Awake()
    {
        int numScenePersist = FindObjectsOfType<Soudrack>().Length;

        if (numScenePersist > 1)
        {
            Destroy(gameObject);
            Debug.Log("destroying scene persistent!");
        }

        else
        {
            DontDestroyOnLoad(this.gameObject);
            Debug.Log("don t destroying scene persistent!");
        }
    }

    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
